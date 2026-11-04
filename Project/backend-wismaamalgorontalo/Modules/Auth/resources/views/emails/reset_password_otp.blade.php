<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kode Reset Password</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: #f4f5f7;
            color: #1a202c;
            line-height: 1.6;
        }
        .container {
            max-width: 560px;
            margin: 40px auto;
            background: #ffffff;
            border-radius: 12px;
            overflow: hidden;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        }
        .header {
            background-color: #0f172a;
            padding: 32px 40px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            color: #ffffff;
            font-size: 22px;
            font-weight: 700;
            letter-spacing: -0.5px;
        }
        .content {
            padding: 40px;
        }
        .greeting {
            font-size: 16px;
            font-weight: 600;
            color: #0f172a;
            margin-bottom: 12px;
        }
        .text {
            font-size: 14px;
            color: #475569;
            margin-bottom: 24px;
        }
        .otp-box {
            background-color: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 8px;
            padding: 24px;
            text-align: center;
            margin: 28px 0;
        }
        .otp-code {
            font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
            font-size: 34px;
            font-weight: 800;
            letter-spacing: 8px;
            color: #0284c7;
            display: inline-block;
        }
        .otp-expiry {
            margin-top: 8px;
            font-size: 12px;
            color: #64748b;
        }
        .security-notice {
            background-color: #fef2f2;
            border-left: 4px solid #ef4444;
            padding: 12px 16px;
            border-radius: 4px;
            font-size: 12px;
            color: #991b1b;
            margin-top: 24px;
        }
        .footer {
            background-color: #f8fafc;
            padding: 20px 40px;
            text-align: center;
            font-size: 12px;
            color: #94a3b8;
            border-top: 1px solid #e2e8f0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>{{ config('app.name', 'Sistem Manajemen Properti & Kost') }}</h1>
        </div>
        <div class="content">
            <div class="greeting">Halo, {{ $userName }}</div>
            <p class="text">
                Kami menerima permintaan untuk mereset kata sandi akun Anda. Gunakan kode verifikasi (OTP) di bawah ini untuk melanjutkan proses pembuatan kata sandi baru.
            </p>

            <div class="otp-box">
                <div class="otp-code">{{ $otp }}</div>
                <div class="otp-expiry">Berlaku selama 15 menit ke depan</div>
            </div>

            <p class="text" style="font-size: 13px;">
                Masukkan kode di atas pada aplikasi untuk memverifikasi identitas Anda. Jangan berikan kode ini kepada siapa pun, termasuk pihak manajemen atau teknisi.
            </p>

            <div class="security-notice">
                Jika Anda tidak pernah meminta reset kata sandi, abaikan email ini. Akun Anda tetap aman dan tidak ada perubahan yang dilakukan.
            </div>
        </div>
        <div class="footer">
            &copy; {{ date('Y') }} {{ config('app.name', 'Smart Kost') }}. Hak Cipta Dilindungi.
        </div>
    </div>
</body>
</html>
