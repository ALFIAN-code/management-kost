<?php

namespace Modules\Auth\Services;

use Carbon\Carbon;
use Exception;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Modules\Auth\Emails\ResetPasswordOtpMail;
use Modules\Auth\Emails\VerifyEmailOtpMail;
use Modules\Auth\Models\User;

class AuthService
{
    public function register(array $data)
    {
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
            ]);

            $user->assignRole('member');

            $token = $user->createToken('auth_token')->plainTextToken;

            // Otomatis kirim OTP verifikasi email via SMTP
            $this->sendEmailVerificationOtp($user);

            return [
                'user' => $user->load('roles'),
                'token' => $token,
                'role' => 'member',
                'must_verify_email' => true,
            ];
        });
    }

    public function login(string $email, string $password): array
    {
        $user = User::where('email', $email)->first();

        if (! $user || ! Hash::check($password, $user->password)) {
            throw new Exception('Kredensial tidak valid', 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return [
            'user' => $user,
            'token' => $token,
            'role' => $user->getRoleNames()->first(),
        ];
    }

    public function logout($user): void
    {
        if ($user) {
            $user->currentAccessToken()->delete();
        }
    }

    /**
     * Mengirimkan kode OTP reset password ke email pengguna melalui SMTP.
     */
    public function sendForgotPasswordOtp(string $email): void
    {
        $user = User::where('email', $email)->first();

        if (! $user) {
            throw new Exception('Alamat email tidak terdaftar dalam sistem.', 404);
        }

        // Generate 6 digit numeric OTP
        $otp = (string) random_int(100000, 999999);

        // Simpan / update di password_reset_tokens
        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $email],
            [
                'token' => $otp,
                'created_at' => Carbon::now(),
            ]
        );

        // Kirim email lewat SMTP
        try {
            Mail::to($email)->send(new ResetPasswordOtpMail($otp, $user->name));
        } catch (\Throwable $th) {
            // Log jika SMTP error tapi jangan crash aplikasi bila mailer misconfigured di dev
            report($th);
        }
    }

    /**
     * Memverifikasi validitas OTP reset password.
     */
    public function verifyResetOtp(string $email, string $otp): bool
    {
        $record = DB::table('password_reset_tokens')
            ->where('email', $email)
            ->first();

        if (! $record) {
            throw new Exception('Permintaan reset kata sandi tidak ditemukan atau sudah kadaluarsa.', 404);
        }

        if ($record->token !== $otp) {
            throw new Exception('Kode OTP yang Anda masukkan salah.', 422);
        }

        // Cek masa berlaku OTP (15 menit)
        if (Carbon::parse($record->created_at)->addMinutes(15)->isPast()) {
            throw new Exception('Kode OTP telah kadaluarsa. Silakan ajukan ulang permintaan baru.', 422);
        }

        return true;
    }

    /**
     * Mereset password pengguna menggunakan OTP.
     */
    public function resetPasswordWithOtp(string $email, string $otp, string $newPassword): void
    {
        $this->verifyResetOtp($email, $otp);

        $user = User::where('email', $email)->first();
        if (! $user) {
            throw new Exception('Pengguna tidak ditemukan.', 404);
        }

        DB::transaction(function () use ($user, $email, $newPassword) {
            $user->update([
                'password' => Hash::make($newPassword),
            ]);

            // Hapus token reset setelah berhasil digunakan
            DB::table('password_reset_tokens')->where('email', $email)->delete();
        });
    }

    /**
     * Mengirimkan kode OTP verifikasi alamat email.
     */
    public function sendEmailVerificationOtp(User $user): void
    {
        $otp = (string) random_int(100000, 999999);

        DB::table('email_verification_tokens')->updateOrInsert(
            ['email' => $user->email],
            [
                'otp' => $otp,
                'created_at' => Carbon::now(),
            ]
        );

        try {
            Mail::to($user->email)->send(new VerifyEmailOtpMail($otp, $user->name));
        } catch (\Throwable $th) {
            report($th);
        }
    }

    /**
     * Memverifikasi alamat email pengguna berdasarkan OTP.
     */
    public function verifyEmailWithOtp(User $user, string $otp): void
    {
        $record = DB::table('email_verification_tokens')
            ->where('email', $user->email)
            ->first();

        if (! $record || $record->otp !== $otp) {
            throw new Exception('Kode verifikasi salah atau tidak ditemukan.', 422);
        }

        if (Carbon::parse($record->created_at)->addMinutes(30)->isPast()) {
            throw new Exception('Kode verifikasi telah kadaluarsa.', 422);
        }

        DB::transaction(function () use ($user) {
            $user->update([
                'email_verified_at' => Carbon::now(),
            ]);

            DB::table('email_verification_tokens')->where('email', $user->email)->delete();
        });
    }

    /**
     * Memverifikasi alamat email via email dan OTP tanpa harus login terlebih dahulu.
     */
    public function verifyEmailOtpByEmail(string $email, string $otp): User
    {
        $record = DB::table('email_verification_tokens')
            ->where('email', $email)
            ->first();

        if (! $record || $record->otp !== $otp) {
            throw new Exception('Kode verifikasi salah atau tidak ditemukan.', 422);
        }

        if (Carbon::parse($record->created_at)->addMinutes(30)->isPast()) {
            throw new Exception('Kode verifikasi telah kadaluarsa.', 422);
        }

        $user = User::where('email', $email)->first();
        if (! $user) {
            throw new Exception('Pengguna dengan email tersebut tidak ditemukan.', 404);
        }

        DB::transaction(function () use ($user, $email) {
            $user->update([
                'email_verified_at' => Carbon::now(),
            ]);

            DB::table('email_verification_tokens')->where('email', $email)->delete();
        });

        return $user;
    }

    /**
     * Kirim ulang kode OTP verifikasi alamat email.
     */
    public function resendVerificationOtpByEmail(string $email): void
    {
        $user = User::where('email', $email)->first();
        if (! $user) {
            throw new Exception('Alamat email tidak terdaftar dalam sistem.', 404);
        }

        if ($user->email_verified_at) {
            throw new Exception('Alamat email ini sudah terverifikasi sebelumnya.', 422);
        }

        $this->sendEmailVerificationOtp($user);
    }

    /**
     * Autentikasi / SSO dengan Google (ID Token verification & JIT Provisioning).
     */
    public function loginWithGoogle(string $idToken): array
    {
        $googleUser = null;

        // Validasi ke endpoint Google tokeninfo
        try {
            $response = Http::timeout(8)->get('https://oauth2.googleapis.com/tokeninfo', [
                'id_token' => $idToken,
            ]);

            if ($response->successful()) {
                $googleUser = $response->json();
            }
        } catch (\Throwable $th) {
            report($th);
        }

        // Fallback untuk mode testing jika token berawalan mock-token-
        if (! $googleUser && app()->environment('testing', 'local') && str_starts_with($idToken, 'mock-google-token-')) {
            $email = str_replace('mock-google-token-', '', $idToken);
            $googleUser = [
                'email' => $email,
                'name' => 'Mock Google User',
                'sub' => 'google_sub_'.md5($email),
                'email_verified' => true,
            ];
        }

        if (! $googleUser || empty($googleUser['email'])) {
            throw new Exception('Token Google tidak valid atau gagal diverifikasi oleh Google.', 401);
        }

        $email = $googleUser['email'];
        $name = $googleUser['name'] ?? explode('@', $email)[0];
        $googleSub = $googleUser['sub'] ?? null;

        $user = User::where('email', $email)->first();

        if (! $user) {
            $user = DB::transaction(function () use ($email, $name, $googleSub) {
                $created = User::create([
                    'name' => $name,
                    'email' => $email,
                    'password' => Hash::make(Str::random(32)),
                    'auth_provider' => 'google',
                    'keycloak_id' => $googleSub,
                    'email_verified_at' => Carbon::now(),
                ]);

                $created->assignRole('member');

                return $created;
            });
        } else {
            // Update auth provider dan verified timestamp jika belum
            $updates = [];
            if (! $user->email_verified_at) {
                $updates['email_verified_at'] = Carbon::now();
            }
            if ($user->auth_provider === 'local' || empty($user->auth_provider)) {
                $updates['auth_provider'] = 'google';
            }
            if (! $user->keycloak_id && $googleSub) {
                $updates['keycloak_id'] = $googleSub;
            }
            if (! empty($updates)) {
                $user->update($updates);
            }
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return [
            'user' => $user->load('roles'),
            'token' => $token,
            'role' => $user->getRoleNames()->first() ?? 'member',
        ];
    }
}
