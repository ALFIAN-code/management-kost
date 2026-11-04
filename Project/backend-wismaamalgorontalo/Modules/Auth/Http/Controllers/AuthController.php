<?php

namespace Modules\Auth\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Modules\Auth\Http\Requests\LoginRequest;
use Modules\Auth\Http\Requests\RegisterRequest;
use Modules\Auth\Services\AuthService;

class AuthController extends Controller
{
    use ApiResponse;

    protected $authService;

    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    /**
     * Registrasi Pengguna
     *
     * Membuat akun baru untuk pengguna/calon penghuni.
     *
     * @unauthenticated
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function register(RegisterRequest $request)
    {
        try {
            $user = $this->authService->register($request->validated());

            return $this->apiSuccess($user, 'Registrasi berhasil', 201);
        } catch (\Exception $e) {
            return $this->apiError($e->getMessage(), 500);
        }
    }

    /**
     * Login Pengguna
     *
     * Melakukan autentikasi pengguna dan mengembalikan token Sanctum.
     *
     * @unauthenticated
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(LoginRequest $request)
    {
        try {
            $data = $this->authService->login(
                $request->email,
                $request->password
            );

            return $this->apiSuccess($data, 'Login berhasil');
        } catch (ValidationException $e) {
            return $this->apiError($e->getMessage(), 401);
        } catch (\Exception $e) {
            return $this->apiError('Terjadi kesalahan sistem', 500);
        }
    }

    /**
     * Logout Pengguna
     *
     * Menghapus token autentikasi pengguna saat ini.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout(Request $request)
    {
        $this->authService->logout($request->user());

        return $this->apiSuccess(null, 'Logout berhasil');
    }

    /**
     * Data Pengguna Saat Ini
     *
     * Mengambil profil pengguna yang sedang terautentikasi.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function me(Request $request)
    {
        // roles wajib di-load: FE (halaman Profil) membaca roles[0].name untuk badge role.
        // Tanpa ini role selalu null dan tampil sebagai 'GUEST'.
        return $this->apiSuccess($request->user()->load('roles'), 'Data user berhasil diambil');
    }

    /**
     * Hak Akses Pengguna
     *
     * Mengambil daftar peran (roles) dan izin (permissions) pengguna saat ini.
     * Jika tidak login, akan mengembalikan role guest.
     *
     * @unauthenticated
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function myPermissions(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = $request->user('sanctum');

        if (! $user) {
            $guestRole = \Spatie\Permission\Models\Role::where('name', 'guest')->where('guard_name', 'api')->first();
            $permissions = $guestRole ? $guestRole->permissions->pluck('name') : collect(['view-room']);

            return $this->apiSuccess([
                'permissions' => $permissions->values()->all(),
                'roles' => ['guest'],
            ], 'Guest permissions retrieved successfully');
        }

        return $this->apiSuccess([
            'permissions' => $user->getAllPermissions()->pluck('name')->values()->all(),
            'roles' => $user->getRoleNames()->values()->all(),
        ], 'User permissions retrieved successfully');
    }

    /**
     * Update Profil
     *
     * Memperbarui nama dan email pengguna saat ini.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,'.$user->id,
        ]);

        $user->update($validated);

        return $this->apiSuccess($user, 'Profil berhasil diperbarui');
    }

    /**
     * Ubah Password
     *
     * Memperbarui password pengguna saat ini.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function changePassword(Request $request)
    {
        $request->validate([
            'old_password' => 'required',
            'new_password' => 'required|min:8|confirmed',
        ]);

        $user = $request->user();

        if (! Hash::check($request->old_password, $user->password)) {
            return $this->apiError('Password lama tidak sesuai', 422);
        }

        $user->update([
            'password' => Hash::make($request->new_password),
        ]);

        return $this->apiSuccess(null, 'Password berhasil diubah');
    }

    /**
     * Minta OTP Lupa Password
     *
     * Mengirimkan kode 6 digit OTP ke alamat email terdaftar melalui SMTP.
     *
     * @unauthenticated
     */
    public function forgotPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        try {
            $this->authService->sendForgotPasswordOtp($request->email);

            return $this->apiSuccess(
                ['email' => $request->email],
                'Kode verifikasi OTP telah dikirimkan ke email Anda. Silakan periksa kotak masuk atau spam.'
            );
        } catch (\Exception $e) {
            return $this->apiError($e->getMessage(), $e->getCode() >= 400 && $e->getCode() < 600 ? $e->getCode() : 500);
        }
    }

    /**
     * Verifikasi OTP Reset Password
     *
     * Memeriksa apakah OTP yang dimasukkan valid dan belum kadaluarsa.
     *
     * @unauthenticated
     */
    public function verifyOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|string|size:6',
        ]);

        try {
            $this->authService->verifyResetOtp($request->email, $request->otp);

            return $this->apiSuccess(
                ['valid' => true],
                'Kode OTP valid. Silakan lanjutkan pembuatan password baru.'
            );
        } catch (\Exception $e) {
            return $this->apiError($e->getMessage(), $e->getCode() >= 400 && $e->getCode() < 600 ? $e->getCode() : 422);
        }
    }

    /**
     * Reset Password dengan OTP
     *
     * Menyimpan password baru setelah verifikasi OTP berhasil.
     *
     * @unauthenticated
     */
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|string|size:6',
            'password' => 'required|string|min:8|confirmed',
        ]);

        try {
            $this->authService->resetPasswordWithOtp($request->email, $request->otp, $request->password);

            return $this->apiSuccess(
                null,
                'Kata sandi Anda berhasil diperbarui. Silakan masuk menggunakan kata sandi baru.'
            );
        } catch (\Exception $e) {
            return $this->apiError($e->getMessage(), $e->getCode() >= 400 && $e->getCode() < 600 ? $e->getCode() : 422);
        }
    }

    /**
     * Kirim Ulang OTP Verifikasi Email
     *
     * Mengirimkan kode verifikasi email untuk akun yang sedang login.
     */
    public function sendEmailVerification(Request $request)
    {
        try {
            $this->authService->sendEmailVerificationOtp($request->user());

            return $this->apiSuccess(
                null,
                'Kode verifikasi email berhasil dikirim ke '.$request->user()->email
            );
        } catch (\Exception $e) {
            return $this->apiError($e->getMessage(), 500);
        }
    }

    /**
     * Verifikasi Email dengan OTP
     */
    public function verifyEmail(Request $request)
    {
        $request->validate([
            'otp' => 'required|string|size:6',
        ]);

        try {
            $this->authService->verifyEmailWithOtp($request->user(), $request->otp);

            return $this->apiSuccess(
                ['email_verified_at' => now()],
                'Alamat email berhasil diverifikasi.'
            );
        } catch (\Exception $e) {
            return $this->apiError($e->getMessage(), $e->getCode() >= 400 && $e->getCode() < 600 ? $e->getCode() : 422);
        }
    }

    /**
     * Verifikasi Email dengan OTP (Bisa Public dengan input email & OTP)
     *
     * @unauthenticated
     */
    public function verifyEmailPublic(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|string|size:6',
        ]);

        try {
            $user = $this->authService->verifyEmailOtpByEmail($request->email, $request->otp);

            return $this->apiSuccess(
                [
                    'email' => $user->email,
                    'email_verified_at' => $user->email_verified_at,
                ],
                'Alamat email berhasil diverifikasi. Akun Anda kini aktif sepenuhnya.'
            );
        } catch (\Exception $e) {
            return $this->apiError($e->getMessage(), $e->getCode() >= 400 && $e->getCode() < 600 ? $e->getCode() : 422);
        }
    }

    /**
     * Kirim Ulang OTP Verifikasi Email (Bisa Public dengan email)
     *
     * @unauthenticated
     */
    public function resendEmailVerification(Request $request)
    {
        $email = $request->email ?? $request->user()?->email;
        if (! $email) {
            return $this->apiError('Alamat email wajib disertakan.', 422);
        }

        try {
            $this->authService->resendVerificationOtpByEmail($email);

            return $this->apiSuccess(
                null,
                'Kode verifikasi baru telah dikirimkan ke '.$email
            );
        } catch (\Exception $e) {
            return $this->apiError($e->getMessage(), $e->getCode() >= 400 && $e->getCode() < 600 ? $e->getCode() : 422);
        }
    }

    /**
     * SSO Google Sign-In
     *
     * Menerima id_token dari Google Sign-In (Flutter/Web), memverifikasi,
     * dan menerbitkan token otentikasi Sanctum (JIT Provisioning).
     *
     * @unauthenticated
     */
    public function googleLogin(Request $request)
    {
        $request->validate([
            'id_token' => 'required|string',
        ]);

        try {
            $data = $this->authService->loginWithGoogle($request->id_token);

            return $this->apiSuccess($data, 'Berhasil masuk dengan akun Google.');
        } catch (\Exception $e) {
            return $this->apiError($e->getMessage(), $e->getCode() >= 400 && $e->getCode() < 600 ? $e->getCode() : 401);
        }
    }
}
