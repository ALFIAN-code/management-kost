<?php

namespace Modules\Auth\tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Modules\Auth\Emails\ResetPasswordOtpMail;
use Modules\Auth\Models\User;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class AuthLifecycleTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Role::create(['name' => 'member', 'guard_name' => 'api']);
    }

    public function test_forgot_password_sends_otp_email_successfully(): void
    {
        Mail::fake();

        $user = User::factory()->create([
            'email' => 'client@example.com',
            'name' => 'Client Test',
        ]);

        $response = $this->postJson('/api/forgot-password', [
            'email' => 'client@example.com',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
            ]);

        Mail::assertSent(ResetPasswordOtpMail::class, function ($mail) {
            return $mail->hasTo('client@example.com');
        });

        $this->assertDatabaseHas('password_reset_tokens', [
            'email' => 'client@example.com',
        ]);
    }

    public function test_verify_otp_validates_correctly(): void
    {
        DB::table('password_reset_tokens')->insert([
            'email' => 'client@example.com',
            'token' => '123456',
            'created_at' => now(),
        ]);

        // Wrong OTP
        $responseWrong = $this->postJson('/api/verify-otp', [
            'email' => 'client@example.com',
            'otp' => '999999',
        ]);
        $responseWrong->assertStatus(422);

        // Correct OTP
        $responseCorrect = $this->postJson('/api/verify-otp', [
            'email' => 'client@example.com',
            'otp' => '123456',
        ]);
        $responseCorrect->assertStatus(200)
            ->assertJson([
                'status' => true,
                'data' => ['valid' => true],
            ]);
    }

    public function test_reset_password_updates_user_password(): void
    {
        $user = User::factory()->create([
            'email' => 'client@example.com',
            'password' => Hash::make('oldpassword123'),
        ]);

        DB::table('password_reset_tokens')->insert([
            'email' => 'client@example.com',
            'token' => '123456',
            'created_at' => now(),
        ]);

        $response = $this->postJson('/api/reset-password', [
            'email' => 'client@example.com',
            'otp' => '123456',
            'password' => 'newpassword12345',
            'password_confirmation' => 'newpassword12345',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
            ]);

        $user->refresh();
        $this->assertTrue(Hash::check('newpassword12345', $user->password));

        // Token should be removed
        $this->assertDatabaseMissing('password_reset_tokens', [
            'email' => 'client@example.com',
        ]);
    }

    public function test_google_login_jit_provisioning(): void
    {
        $response = $this->postJson('/api/google-login', [
            'id_token' => 'mock-google-token-googleclient@example.com',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'googleclient@example.com',
            'auth_provider' => 'google',
        ]);
    }

    public function test_register_dispatches_email_verification_otp(): void
    {
        Mail::fake();

        $response = $this->postJson('/api/register', [
            'name' => 'Calon Penghuni Baru',
            'email' => 'calon@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'status' => true,
                'data' => [
                    'must_verify_email' => true,
                ],
            ]);

        Mail::assertSent(\Modules\Auth\Emails\VerifyEmailOtpMail::class, function ($mail) {
            return $mail->hasTo('calon@example.com');
        });

        $this->assertDatabaseHas('email_verification_tokens', [
            'email' => 'calon@example.com',
        ]);
    }

    public function test_verify_email_public_activates_account(): void
    {
        $user = User::factory()->create([
            'email' => 'verify@example.com',
            'email_verified_at' => null,
        ]);

        DB::table('email_verification_tokens')->insert([
            'email' => 'verify@example.com',
            'otp' => '654321',
            'created_at' => now(),
        ]);

        $response = $this->postJson('/api/email/verify-otp', [
            'email' => 'verify@example.com',
            'otp' => '654321',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
            ]);

        $user->refresh();
        $this->assertNotNull($user->email_verified_at);
        $this->assertDatabaseMissing('email_verification_tokens', [
            'email' => 'verify@example.com',
        ]);
    }
}
