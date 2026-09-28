<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>Log in - Attendance</title>
    <link rel="icon" href="{{ asset('image/attendance system logo.png') }}" type="image/png">

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600,700,800,900&display=swap" rel="stylesheet" />

    <!-- Icons (matches layouts/app.blade.php) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css"
        integrity="sha512-Evv84Mr4kqVGRNSgIGL/F/aIDqQb7xQ2vcrdIwxfjThSH8CSR7PBEakCr51Ck+w+/U6swU2Im1vVX0SVk9ABhg=="
        crossorigin="anonymous" referrerpolicy="no-referrer" />

    @vite(['resources/css/app.css', 'resources/js/app.js'])

    <style>
        :root {
            --gd: #123524;
            --gm: #1c4d34;
            --gl: #2c8a2c;
            --ac: #f2b705;
            --cr: #f3f6f4;
            --bd: #dfe7e2;
            --tm: #5b6b63;
        }

        body {
            font-family: 'Figtree', sans-serif;
        }

        .login-wrap {
            display: flex;
            min-height: 100vh;
        }

        /* ── LEFT PANEL ── */
        .left-panel {
            width: 48%;
            background: var(--gd);
            background-image:
                radial-gradient(circle at 25% 20%, rgba(44, 138, 44, .45) 0%, transparent 50%),
                radial-gradient(circle at 85% 85%, rgba(242, 183, 5, .12) 0%, transparent 45%);
            position: relative;
            display: flex;
            flex-direction: column;
            padding: 48px 56px;
            overflow: hidden;
        }

        .left-panel::before {
            content: '';
            position: absolute;
            inset: 0;
            background-image:
                linear-gradient(rgba(242, 183, 5, .05) 1px, transparent 1px),
                linear-gradient(90deg, rgba(242, 183, 5, .05) 1px, transparent 1px);
            background-size: 48px 48px;
            pointer-events: none;
        }

        .deco-circle {
            position: absolute;
            width: 460px;
            height: 460px;
            border-radius: 50%;
            border: 1px solid rgba(242, 183, 5, .10);
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            animation: pulseRing 4s ease-in-out infinite;
        }

        .deco-circle.c2 {
            width: 320px;
            height: 320px;
            border-color: rgba(242, 183, 5, .16);
            animation-delay: 1s;
        }

        @keyframes pulseRing {
            0%, 100% { opacity: .6; transform: translate(-50%, -50%) scale(1); }
            50% { opacity: 1; transform: translate(-50%, -50%) scale(1.04); }
        }

        .left-logo {
            position: relative;
            z-index: 1;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .left-brand {
            font-weight: 800;
            font-size: 20px;
            color: #fff;
            letter-spacing: -.3px;
        }

        .left-brand span {
            color: var(--ac);
        }

        .left-main {
            position: relative;
            z-index: 1;
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .left-eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(242, 183, 5, .12);
            border: 1px solid rgba(242, 183, 5, .25);
            border-radius: 50px;
            padding: 6px 16px;
            font-size: 12px;
            font-weight: 700;
            color: var(--ac);
            letter-spacing: .5px;
            text-transform: uppercase;
            margin-bottom: 24px;
        }

        .left-eyebrow .dot {
            width: 6px;
            height: 6px;
            background: var(--ac);
            border-radius: 50%;
            animation: blink 1.8s ease-in-out infinite;
        }

        @keyframes blink {
            0%, 100% { opacity: 1 }
            50% { opacity: .3 }
        }

        .left-headline {
            font-weight: 800;
            font-size: clamp(30px, 3.2vw, 44px);
            color: #fff;
            line-height: 1.1;
            letter-spacing: -.5px;
            margin-bottom: 18px;
        }

        .left-headline em {
            font-style: normal;
            color: var(--ac);
        }

        .left-desc {
            font-size: 15px;
            color: rgba(255, 255, 255, .55);
            line-height: 1.6;
            max-width: 380px;
            margin-bottom: 32px;
        }

        .feat-list {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .feat-card {
            display: flex;
            align-items: center;
            gap: 14px;
            background: rgba(255, 255, 255, .05);
            border: 1px solid rgba(255, 255, 255, .1);
            border-radius: 14px;
            padding: 13px 18px;
            transition: background .2s, border-color .2s, transform .2s;
        }

        .feat-card:hover {
            background: rgba(255, 255, 255, .09);
            border-color: rgba(242, 183, 5, .3);
            transform: translateX(4px);
        }

        .feat-icon {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            flex-shrink: 0;
            background: rgba(242, 183, 5, .15);
            color: var(--ac);
        }

        .feat-title {
            font-weight: 700;
            font-size: 13px;
            color: #fff;
        }

        .feat-desc {
            font-size: 11px;
            color: rgba(255, 255, 255, .45);
            margin-top: 1px;
        }

        .left-footer {
            position: relative;
            z-index: 1;
            font-size: 12px;
            color: rgba(255, 255, 255, .3);
        }

        /* ── RIGHT PANEL ── */
        .right-panel {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 48px;
            background: var(--cr);
            position: relative;
        }

        .form-box {
            width: 100%;
            max-width: 400px;
            animation: fadeUp .5s ease both;
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px) }
            to { opacity: 1; transform: translateY(0) }
        }

        .form-title {
            font-weight: 800;
            font-size: 28px;
            color: var(--gd);
            letter-spacing: -.5px;
            line-height: 1.15;
            margin-bottom: 8px;
        }

        .form-title em {
            font-style: normal;
            color: var(--gl);
        }

        .form-sub {
            font-size: 14px;
            color: var(--tm);
            margin-bottom: 28px;
            line-height: 1.5;
        }

        .field-label {
            display: block;
            font-size: 13px;
            font-weight: 700;
            color: var(--gd);
            margin-bottom: 6px;
        }

        .input-wrap {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--tm);
            font-size: 14px;
            pointer-events: none;
        }

        .input-wrap:focus-within .input-icon {
            color: var(--gl);
        }

        .form-input {
            width: 100%;
            border: 1.5px solid var(--bd);
            border-radius: 12px;
            padding: 12px 14px 12px 40px;
            font-size: 14px;
            background: #fff;
            color: var(--gd);
            outline: none;
            transition: border-color .2s, box-shadow .2s;
        }

        .form-input:focus {
            border-color: var(--gl);
            box-shadow: 0 0 0 3px rgba(44, 138, 44, .12);
        }

        .form-input.is-invalid {
            border-color: #dc3545 !important;
            box-shadow: 0 0 0 3px rgba(220, 53, 69, .12) !important;
        }

        .field-error {
            font-size: 12px;
            color: #dc3545;
            font-weight: 600;
            margin-top: 5px;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .pw-toggle {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: var(--tm);
            font-size: 14px;
            cursor: pointer;
        }

        .pw-toggle:hover {
            color: var(--gd);
        }

        .btn-login {
            width: 100%;
            background: var(--gd);
            color: #fff;
            font-weight: 800;
            font-size: 15px;
            padding: 14px;
            border-radius: 50px;
            border: none;
            cursor: pointer;
            transition: background .2s, transform .15s, box-shadow .2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            box-shadow: 0 4px 16px rgba(18, 53, 36, .2);
        }

        .btn-login:hover {
            background: var(--gm);
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(18, 53, 36, .28);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        .btn-login .spinner {
            width: 16px;
            height: 16px;
            border: 2.5px solid rgba(255, 255, 255, .3);
            border-top-color: #fff;
            border-radius: 50%;
            animation: spin .7s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        .error-box {
            background: #fde8e8;
            border: 1.5px solid #f0c0c0;
            border-radius: 12px;
            padding: 12px 16px;
            font-size: 13px;
            font-weight: 600;
            color: #8b1a1a;
            display: flex;
            align-items: flex-start;
            gap: 10px;
            margin-bottom: 18px;
        }

        .status-box {
            background: #e8f5e9;
            border: 1.5px solid #a5d6a7;
            border-radius: 12px;
            padding: 12px 16px;
            font-size: 13px;
            font-weight: 600;
            color: var(--gd);
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 18px;
        }

        .right-footer {
            position: absolute;
            bottom: 20px;
            left: 0;
            right: 0;
            text-align: center;
            font-size: 12px;
            color: var(--bd);
        }

        @media (max-width: 860px) {
            .login-wrap {
                flex-direction: column;
            }

            .left-panel {
                width: 100%;
                padding: 32px 28px;
            }

            .deco-circle,
            .feat-list {
                display: none;
            }

            .right-panel {
                padding: 40px 28px 60px;
            }
        }
    </style>
</head>
<body class="antialiased">

    <div class="login-wrap">

        <div class="left-panel">
            <div class="deco-circle"></div>
            <div class="deco-circle c2"></div>

            <a href="/" class="left-logo">
                <img src="{{ asset('image/AttendanceSystemLogo.png') }}" alt="Attendance" style="width:160px;height:160px;object-fit:contain">
            </a>

            <div class="left-main">
                <div class="left-eyebrow">
                    <div class="dot"></div>Biometric Attendance Portal
                </div>
                <h1 class="left-headline">TRACK TIME.<br>MANAGE <em>OVERTIME.</em><br>STAY <em>ON SCHEDULE.</em></h1>
                <p class="left-desc">Sign in to view attendance records, review overtime, and manage schedule adjustments and certificates for your department.</p>

                <div class="feat-list">
                    <div class="feat-card">
                        <div class="feat-icon"><i class="fa-solid fa-fingerprint"></i></div>
                        <div>
                            <div class="feat-title">Biometric Time Records</div>
                            <div class="feat-desc">Daily punches synced straight from the biometric device</div>
                        </div>
                    </div>
                    <div class="feat-card">
                        <div class="feat-icon"><i class="fa-solid fa-clock"></i></div>
                        <div>
                            <div class="feat-title">Automated Overtime</div>
                            <div class="feat-desc">ORD, RD, and night differential computed automatically</div>
                        </div>
                    </div>
                    <div class="feat-card">
                        <div class="feat-icon"><i class="fa-solid fa-calendar-check"></i></div>
                        <div>
                            <div class="feat-title">Schedule Adjustments</div>
                            <div class="feat-desc">Request and approve schedule changes with a clear audit trail</div>
                        </div>
                    </div>
                    <div class="feat-card">
                        <div class="feat-icon"><i class="fa-solid fa-certificate"></i></div>
                        <div>
                            <div class="feat-title">Certificates of Attendance</div>
                            <div class="feat-desc">Finalize and export certificates ready for payroll</div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="left-footer">&copy; {{ date('Y') }} Attendance Management System. All rights reserved.</div>
        </div>

        <div class="right-panel">
            <div class="form-box">
                {{ $slot }}
            </div>
            <div class="right-footer">Attendance System &nbsp;&middot;&nbsp; Secure internal access</div>
        </div>

    </div>

</body>
</html>
