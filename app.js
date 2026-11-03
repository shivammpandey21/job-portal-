// Accessible theme toggle with a persisted preference.
(function () {
    var root = document.documentElement;
    var saved = localStorage.getItem('jp-theme');
    if (saved === 'dark') root.setAttribute('data-theme', 'dark');
    document.addEventListener('click', function (event) {
        var toggle = event.target.closest('[data-theme-toggle]');
        if (!toggle) return;
        var dark = root.getAttribute('data-theme') !== 'dark';
        if (dark) {
            root.setAttribute('data-theme', 'dark');
            localStorage.setItem('jp-theme', 'dark');
            toggle.innerHTML = '<i class="bi bi-sun"></i>';
            toggle.setAttribute('aria-label', 'Switch to light mode');
        } else {
            root.removeAttribute('data-theme');
            localStorage.setItem('jp-theme', 'light');
            toggle.innerHTML = '<i class="bi bi-moon-stars"></i>';
            toggle.setAttribute('aria-label', 'Switch to dark mode');
        }
    });
    if (saved === 'dark') {
        var button = document.querySelector('[data-theme-toggle]');
        if (button) {
            button.innerHTML = '<i class="bi bi-sun"></i>';
            button.setAttribute('aria-label', 'Switch to light mode');
        }
    }
})();

// Confirm destructive actions.
document.addEventListener('submit', function (e) {
    var msg = e.target.dataset ? e.target.dataset.confirm : null;
    if (msg && !confirm(msg)) { e.preventDefault(); e.stopImmediatePropagation(); }
}, true);

// Loading state on submit buttons.
document.addEventListener('submit', function (e) {
    if (e.defaultPrevented || e.target.hasAttribute('data-no-loading')) return;
    var btn = e.submitter || e.target.querySelector('button[type="submit"], button:not([type])');
    if (!btn) return;
    setTimeout(function () {
        if (e.defaultPrevented) return;
        btn.disabled = true;
        btn.dataset.original = btn.innerHTML;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status"></span>Please wait...';
    }, 0);
});

window.addEventListener('pageshow', function (e) {
    if (!e.persisted) return;
    document.querySelectorAll('button[data-original]').forEach(function (b) {
        b.disabled = false;
        b.innerHTML = b.dataset.original;
    });
});
