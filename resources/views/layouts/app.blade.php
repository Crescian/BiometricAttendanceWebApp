<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>Attendance</title>
    <link rel="icon" href="{{ asset('image/attendance system logo.png') }}" type="image/png">

    {{-- Tailwind --}}
    <script src="https://cdn.tailwindcss.com"></script>

    {{-- Sweet Alert 2 --}}
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/sweetalert2/11.14.4/sweetalert2.min.js"
        integrity="sha512-a/ljmGyCvVDl+QZXCxw/6hKcG4V7Syo7qmb9lUFTwrP12lCCItvQKeTMBMjtpa+3RE6UZ7gk+/IZzj4H04y4ng=="
        crossorigin="anonymous" referrerpolicy="no-referrer"></script>

    {{-- Icons --}}
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css"
        integrity="sha512-Evv84Mr4kqVGRNSgIGL/F/aIDqQb7xQ2vcrdIwxfjThSH8CSR7PBEakCr51Ck+w+/U6swU2Im1vVX0SVk9ABhg=="
        crossorigin="anonymous" referrerpolicy="no-referrer" />

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />

    {{-- jQuery --}}
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js"
        integrity="sha512-v2CJ7UaYy4JwqLDIrZUI/4hqeoQieOmAZNXBeQyjo21dadnwR+8ZaIJVT8EE2iyI61OV8e6M8PP2/4hpQINQ/g=="
        crossorigin="anonymous" referrerpolicy="no-referrer"></script>

    {{-- Flatpickr --}}
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">

    <!-- DataTables Core -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css">
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>

    <!-- DataTables Buttons Extension (Export) -->
    <link rel="stylesheet" href="https://cdn.datatables.net/buttons/2.4.1/css/buttons.dataTables.min.css">
    <script src="https://cdn.datatables.net/buttons/2.4.1/js/dataTables.buttons.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.html5.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.print.min.js"></script>

    <!-- Responsive Extension -->
    <link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.dataTables.min.css">
    <script src="https://cdn.datatables.net/responsive/2.5.0/js/dataTables.responsive.min.js"></script>

    <!-- Column Visibility -->
    <script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.colVis.min.js"></script>

    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.tailwind.min.css">

    <!-- Select2 -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

    <!-- Flatpickr JS -->
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>

    <!-- Scripts -->
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<style>
    .progress {
        background: rgba(255, 255, 255, 0.1);
        justify-content: flex-start;
        border-radius: 100px;
        align-items: center;
        position: relative;
        padding: 0 5px;
        display: flex;
        height: 40px;
        width: 500px;
    }

    .progress-value {
        animation: load 3s normal forwards;
        box-shadow: 0 10px 40px -10px #2c8a2c;
        border-radius: 100px;
        background: #2c8a2c;
        height: 30px;
        width: 0;
    }

    @keyframes load {
        0% {
            width: 0;
        }

        100% {
            width: 100%;
        }
    }
</style>

<body class="font-sans antialiased">
    <!-- 🌟 Global Loading Screen -->
    <div id="page-loader"
        class="fixed inset-0 bg-white flex flex-col items-center justify-center z-50 transition-opacity duration-500">
        <div class="flex flex-col items-center justify-center">
            <!-- Logo Image -->
            <img src="{{ asset('image/AttendanceSystemLogoWithColor.png') }}" alt="HourTrack Logo"
                class="w-96 h-64 animate-pulse select-none" style="margin-top: -50px;">
            <div class="progress" style="margin-top: -50px; margin-left: 20px;">
                <div class="progress-value"></div>
            </div>
            <!-- Loading Text -->
            {{-- <p class="text-gray-600 text-base font-medium tracking-wide text-center"
                style="margin-top: -50px; margin-left: 20px;">
                Loading, please wait...
            </p> --}}
        </div>
    </div>

    <div class="min-h-screen flex flex-col">
        {{-- Navigation --}}
        @include('layouts.navigation')

        {{-- Page Heading --}}
        @if (isset($header))
            <header class="bg-white shadow">
                <div class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
                    {{ $header }}
                </div>
            </header>
        @endif

        {{-- Page Content --}}
        <main class="flex-grow">
            {{ $slot }}
        </main>

        <span class="text-white">Developed by CML and FLL</span>
        <footer class="bg-white border-t border-gray-200 mt-10">
            <div
                class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8 flex flex-col items-center text-gray-600 text-sm space-y-2">
                <p class="flex items-center space-x-2">
                    <img src="{{ asset('image/LGICT.png') }}" alt="LGICT Logo" class="h-5 w-auto">
                    <span>&copy; {{ date('Y') }}</span>
                    <span class="font-semibold text-green-600">Attendance System</span>
                    <span>. All rights reserved.</span>
                </p>
                {{-- <p class="text-gray-500">
                    Developed by <span class="font-semibold text-green-600">CML</span> and <span
                        class="font-semibold text-green-600">FLL</span>
                </p> --}}
            </div>
        </footer>
    </div>

    <!-- 💬 Floating Technical Service Chat -->
    <div id="chat-container" class="fixed bottom-6 right-6 z-50">
        <!-- Chat Button -->
        <button id="chat-toggle"
            class="bg-green-600 hover:bg-green-700 text-white font-medium px-6 py-3 rounded-full shadow-lg transition-all duration-300 flex items-center gap-2 text-sm">
            <i class="fa-solid fa-headset text-lg"></i>
            Technical Service
        </button>

        <!-- Chat Box -->
        <div id="chat-box"
            class="hidden flex flex-col justify-between bg-white rounded-2xl shadow-2xl w-[420px] h-[550px] mt-4 overflow-hidden transform scale-95 opacity-0 transition-all duration-300 border border-gray-200">

            <!-- Header -->
            <div class="bg-green-600 text-white flex items-center justify-between px-5 py-4">
                <span class="font-semibold text-lg">Technical Support</span>
                <button id="chat-close" class="text-white hover:text-gray-200 text-xl">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <!-- Messages -->
            <div id="chat-messages" class="flex-1 overflow-y-auto p-5 space-y-4 text-[15px] text-gray-700 bg-gray-50">
                <!-- Messages will appear here -->
            </div>

            <!-- Input -->
            <div class="border-t border-gray-200 p-4 bg-white flex items-center gap-3">
                <input id="chat-input" type="text" placeholder="Type your message..."
                    class="flex-1 border rounded-xl px-4 py-3 text-sm focus:ring-2 focus:ring-green-400 outline-none">
                <button id="chat-send"
                    class="bg-green-600 hover:bg-green-700 text-white px-4 py-3 rounded-xl flex items-center justify-center">
                    <i class="fa-solid fa-paper-plane"></i>
                </button>
            </div>
        </div>
    </div>
</body>

<!-- 🌟 Loader Script -->
<script>
    $(document).ready(function() {
        function openChat() {
            $("#chat-box").removeClass("hidden").animate({
                opacity: 1,
                scale: 1
            }, 200);
            setTimeout(() => addBotMessage("👋 Hello! How can I assist you? Any concern?"), 400);
        }

        function closeChat() {
            $("#chat-box").animate({
                opacity: 0,
                scale: 0.95
            }, 200, function() {
                $(this).addClass("hidden");
            });
        }

        function sendMessage() {
            let message = $("#chat-input").val().trim();
            if (message === "") return;

            addUserMessage(message);
            $("#chat-input").val("");

            setTimeout(() => {
                addBotMessage("✅ Thanks for reaching out! Our team will respond shortly. 😊");
            }, 800);
        }

        function addUserMessage(text) {
            let msg = `
                <div class="flex justify-end">
                    <div class="bg-green-100 text-green-900 px-3 py-2 rounded-xl max-w-[70%]">
                        ${text}
                    </div>
                </div>`;
            $("#chat-messages").append(msg);
            scrollToBottom();
        }

        function addBotMessage(text) {
            let msg = `
                <div class="flex justify-start">
                    <div class="bg-gray-100 text-gray-800 px-3 py-2 rounded-xl max-w-[70%]">
                        ${text}
                    </div>
                </div>`;
            $("#chat-messages").append(msg);
            scrollToBottom();
        }

        function scrollToBottom() {
            $("#chat-messages").stop().animate({
                scrollTop: $("#chat-messages")[0].scrollHeight
            }, 500);
        }

        // Event bindings
        $("#chat-toggle").on("click", openChat);
        $("#chat-close").on("click", closeChat);
        $("#chat-send").on("click", sendMessage);
        $("#chat-input").on("keypress", function(e) {
            if (e.which === 13) sendMessage();
        });
    });

    document.addEventListener("DOMContentLoaded", () => {
        const loader = document.getElementById("page-loader");
        if (loader) {
            // Fade out when the page is fully loaded
            setTimeout(() => {
                loader.classList.add("opacity-0");
                setTimeout(() => loader.style.display = "none", 500);
            }, 300);
        }
    });

    // Show loader on internal navigation clicks
    document.addEventListener("click", (e) => {
        const target = e.target.closest("a");
        if (
            target &&
            target.href &&
            !target.target &&
            !target.hasAttribute("data-no-loader") &&
            target.href.startsWith(window.location.origin)
        ) {
            const loader = document.getElementById("page-loader");
            loader.style.display = "flex";
            loader.classList.remove("opacity-0");
        }
    });

    // Show loader on form submission
    document.addEventListener("submit", () => {
        const loader = document.getElementById("page-loader");
        loader.style.display = "flex";
        loader.classList.remove("opacity-0");
    });

    
    window.addEventListener("pageshow", function(event) {
        if (event.persisted) {
            const loader = document.getElementById("page-loader");
            if (loader) {
                loader.style.display = "none";
                loader.classList.add("opacity-0");
            }
        }
    });
</script>

</html>
