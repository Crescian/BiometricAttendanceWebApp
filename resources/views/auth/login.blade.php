<x-guest-login-layout>
    <div class="text-xs font-bold uppercase tracking-wide mb-2" style="color:var(--tm)">Welcome back</div>
    <h2 class="form-title">Sign in to<br><em>Attendance System</em></h2>
    <p class="form-sub">Use your registered email and password to access your dashboard.</p>

    @if (session('status'))
        <div class="status-box">
            <i class="fa-solid fa-circle-check"></i>
            {{ session('status') }}
        </div>
    @endif

    @if ($errors->any())
        <div class="error-box">
            <i class="fa-solid fa-circle-exclamation" style="margin-top:1px"></i>
            <ul class="list-none m-0 p-0">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form method="POST" action="{{ route('login') }}" x-data="{ loading: false, showPw: false }" @submit="loading = true">
        @csrf

        <!-- Email Address -->
        <div class="mb-4">
            <label for="email" class="field-label">Email</label>
            <div class="input-wrap">
                <input id="email" type="email" name="email" value="{{ old('email') }}" required autofocus
                    autocomplete="username" placeholder="you@example.com"
                    class="form-input @error('email') is-invalid @enderror">
                <i class="fa-solid fa-envelope input-icon"></i>
            </div>
            @error('email')
                <div class="field-error"><i class="fa-solid fa-circle-exclamation"></i>{{ $message }}</div>
            @enderror
        </div>

        <!-- Password -->
        <div class="mb-4">
            <label for="password" class="field-label">Password</label>
            <div class="input-wrap">
                <input id="password" :type="showPw ? 'text' : 'password'" name="password" required
                    autocomplete="current-password" placeholder="Enter your password" style="padding-right:42px"
                    class="form-input @error('password') is-invalid @enderror">
                <i class="fa-solid fa-lock input-icon"></i>
                <button type="button" class="pw-toggle" tabindex="-1" @click="showPw = !showPw">
                    <i class="fa-solid" :class="showPw ? 'fa-eye-slash' : 'fa-eye'"></i>
                </button>
            </div>
            @error('password')
                <div class="field-error"><i class="fa-solid fa-circle-exclamation"></i>{{ $message }}</div>
            @enderror
        </div>

        <!-- Remember Me + Forgot Password -->
        <div class="flex items-center justify-between mb-6">
            <label class="flex items-center gap-2 text-sm font-semibold cursor-pointer" style="color:var(--tm)">
                <input id="remember_me" type="checkbox" name="remember" {{ old('remember') ? 'checked' : '' }}
                    style="accent-color:var(--gd)" class="rounded">
                Remember me
            </label>
            @if (Route::has('password.request'))
                <a href="{{ route('password.request') }}" class="text-sm font-bold hover:underline" style="color:var(--gl)">
                    Forgot password?
                </a>
            @endif
        </div>

        <!-- Submit -->
        <button type="submit" class="btn-login" :disabled="loading">
            <span x-show="loading" class="spinner"></span>
            <span x-show="!loading"><i class="fa-solid fa-arrow-right-to-bracket"></i> Log in</span>
            <span x-show="loading">Signing in&hellip;</span>
        </button>
    </form>
</x-guest-login-layout>
