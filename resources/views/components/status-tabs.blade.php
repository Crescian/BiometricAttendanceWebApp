{{--
    Full-width status tabs across the top of a table card, with count badges.
    Clicking a tab calls the page's loader, e.g. loadOvertime('Approved'). The count badges keep the ids
    pending-count / approved-count / cancelled-count that the pages' count functions fill in.
    Pass :tabs (each with value, label, title, count, badge) for tabs other than Pending / Approved / Cancelled.
--}}
@props([
    'loader',
    'values' => ['Pending', 'Approved', 'Cancelled'],
    'tabs' => null,
])

@php
    $tabs = $tabs ?? [
        ['value' => $values[0], 'label' => 'Pending', 'title' => 'Pending / Resubmitted for editing', 'count' => 'pending-count', 'badge' => 'bg-yellow-100 text-yellow-800'],
        ['value' => $values[1], 'label' => 'Approved', 'title' => 'Approved', 'count' => 'approved-count', 'badge' => 'bg-green-100 text-green-800'],
        ['value' => $values[2], 'label' => 'Rejected / Cancelled', 'title' => 'Rejected / Cancelled', 'count' => 'cancelled-count', 'badge' => 'bg-red-100 text-red-800'],
    ];
    $activeClasses = 'bg-white text-gray-900 border-gray-200';
    $idleClasses = 'bg-gray-50 text-gray-500 border-transparent hover:text-gray-800';
@endphp

<div class="flex border-b border-gray-200 bg-gray-50 rounded-t-lg" role="tablist">
    @foreach ($tabs as $i => $tab)
        <button type="button" role="tab" data-status-tab title="{{ $tab['title'] }}"
            aria-selected="{{ $i === 0 ? 'true' : 'false' }}"
            onclick="{{ $loader }}('{{ $tab['value'] }}'); setActiveStatusTab(this);"
            class="flex-1 flex items-center gap-2 px-4 py-2 -mb-px text-xs font-medium text-left border-x border-t first:rounded-tl-lg last:rounded-tr-lg transition duration-150 ease-in-out
                {{ $i === 0 ? $activeClasses : $idleClasses }}">
            <span>{{ $tab['label'] }}</span>
            <span id="{{ $tab['count'] }}"
                class="min-w-[1.25rem] px-1.5 py-0.5 rounded-full text-[11px] font-semibold text-center {{ $tab['badge'] }}">0</span>
        </button>
    @endforeach
</div>

@once
    <script>
        function setActiveStatusTab(button) {
            const active = @json(explode(' ', $activeClasses));
            const idle = @json(explode(' ', $idleClasses));
            button.parentElement.querySelectorAll('[data-status-tab]').forEach(function(tab) {
                const isActive = tab === button;
                tab.classList.remove(...(isActive ? idle : active));
                tab.classList.add(...(isActive ? active : idle));
                tab.setAttribute('aria-selected', isActive ? 'true' : 'false');
            });
        }
    </script>
@endonce
