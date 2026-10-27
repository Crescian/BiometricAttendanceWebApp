{{--
    Per-page help: a "Help" tab on the right edge opens a side panel with the instructions in
    resources/views/help/<page>.blade.php. Pages without a help file show no tab.
--}}
@php
    // route name => help file (resources/views/help/...)
    $helpPages = [
        'dashboard' => 'dashboard',
        'ot.approval' => 'overtime',
        'certificate.attendance' => 'certificates',
        'leave' => 'leaves',
        'schedule.adjustment' => 'schedule-adjustment',
        'attendance.record' => 'attendance-record',
        'employee.management' => 'employee-management',
        'report.generation' => 'report-generation',
        'csv.import' => 'biometric-data-import',
        'biometric.data' => 'employee-data-import',
        'organization.structure' => 'organization-structure',
        'user.management' => 'user-management',
        'attendance.log' => 'audit-log',
        'audit.log' => 'audit-log',
    ];
    $helpView = null;
    foreach ($helpPages as $routeName => $file) {
        if (request()->routeIs($routeName) && view()->exists("help.{$file}")) {
            $helpView = "help.{$file}";
        }
    }
@endphp

@if ($helpView)
    <style>
        .page-help h3 { margin: 1.25rem 0 .5rem; font-size: .95rem; font-weight: 600; color: #111827; }
        .page-help h3:first-child { margin-top: 0; }
        .page-help h4 { margin: .9rem 0 .35rem; font-size: .85rem; font-weight: 600; color: #1f2937; }
        .page-help p { margin: .4rem 0; }
        .page-help ol { list-style: decimal; padding-left: 1.25rem; margin: .4rem 0; }
        .page-help ul { list-style: disc; padding-left: 1.25rem; margin: .4rem 0; }
        .page-help li { margin: .25rem 0; }
        .page-help b, .page-help strong { color: #111827; }
        .page-help .help-tip, .page-help .help-warn {
            margin: .75rem 0; padding: .6rem .75rem; border-radius: .375rem; border: 1px solid;
        }
        .page-help .help-tip { background: #f0fdf4; border-color: #bbf7d0; color: #14532d; }
        .page-help .help-warn { background: #fffbeb; border-color: #fde68a; color: #78350f; }
        .page-help .help-admin {
            display: inline-block; margin-left: .25rem; padding: 0 .4rem; border-radius: 9999px;
            font-size: .65rem; font-weight: 600; background: #e0e7ff; color: #3730a3; vertical-align: middle;
        }
        .page-help .help-btn {
            display: inline-flex; align-items: center; gap: .25rem; padding: 0 .35rem; border: 1px solid #d1d5db;
            border-radius: .25rem; background: #f9fafb; font-size: .7rem; font-weight: 500; color: #374151; white-space: nowrap;
        }
    </style>

    <div x-data="{ helpOpen: false }" @keydown.escape.window="helpOpen = false">
        {{-- Tab on the right edge --}}
        <button type="button" @click="helpOpen = true" aria-label="How to use this page"
            class="fixed right-0 top-1/2 -translate-y-1/2 z-30 flex flex-col items-center gap-1.5 px-1.5 py-3 rounded-l-md text-white text-xs font-semibold shadow-lg hover:px-2 transition-all"
            style="background-color: #00291B;">
            <i class="fa-solid fa-circle-question"></i>
            <span style="writing-mode: vertical-rl;">Help</span>
        </button>

        {{-- Side panel --}}
        <div x-cloak x-show="helpOpen" x-transition.opacity @click="helpOpen = false"
            class="fixed inset-0 z-40 bg-black/40"></div>
        <aside x-cloak x-show="helpOpen"
            x-transition:enter="transition ease-out duration-200" x-transition:enter-start="translate-x-full" x-transition:enter-end="translate-x-0"
            x-transition:leave="transition ease-in duration-150" x-transition:leave-start="translate-x-0" x-transition:leave-end="translate-x-full"
            class="fixed inset-y-0 right-0 z-50 w-full max-w-lg flex flex-col bg-white shadow-2xl"
            role="dialog" aria-modal="true" aria-labelledby="page-help-title">
            <div class="flex items-center justify-between gap-3 px-5 py-4 text-white" style="background-color: #00291B;">
                <h2 id="page-help-title" class="flex items-center gap-2 text-base font-semibold">
                    <i class="fa-solid fa-circle-question"></i> How to use this page
                </h2>
                <button type="button" @click="helpOpen = false" class="text-white/80 hover:text-white text-lg" aria-label="Close help">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
            <div class="page-help flex-1 overflow-y-auto px-5 py-4 text-sm text-gray-700 leading-relaxed">
                @include($helpView)
            </div>
            <div class="px-5 py-3 border-t border-gray-200 text-xs text-gray-500">
                <span class="help-admin" style="margin-left:0">Admin</span> marks steps only admins can do.
                Press <b>Esc</b> or click outside to close.
            </div>
        </aside>
    </div>
@endif
