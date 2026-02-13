/* Theme Auto-Apply JS - In    // Setup theme toggle button if exists (optional)
    const btn = document.getElementById('themeToggle');
    console.log('Theme: Theme button found:', !!btn);
    console.log('Theme: Button element:', btn);

    if (btn) {
        // Remove any existing event listeners first
        btn.removeEventListener('click', handleThemeToggle);
        
        function handleThemeToggle() {
            console.log('Theme: Toggle button clicked');
            document.body.classList.toggle('dark');
            const isDark = document.body.classList.contains('dark');
            localStorage.setItem('theme', isDark ? 'dark' : 'light');
            console.log('Theme: Switched to', isDark ? 'dark' : 'light', 'theme');
        }
        
        btn.addEventListener('click', handleThemeToggle);
        console.log('Theme: Event listener added to theme button');
        
        // Test button visibility and click handler
        console.log('Theme: Button styles:', window.getComputedStyle(btn).display);
        console.log('Theme: Button disabled:', btn.disabled);
    } else {
        console.error('Theme: themeToggle button not found in DOM!');
        // Try to find button with different approach
        setTimeout(() => {
            const btn2 = document.querySelector('[id="themeToggle"]');
            const btn3 = document.querySelector('.theme-toggle');
            console.log('Theme: Alternative search - by selector:', !!btn2);
            console.log('Theme: Alternative search - by class:', !!btn3);
        }, 500);
    }ages */
(function () {
    console.log('Theme: Pre-loading dark theme check...');
    // Apply theme immediately when script loads (before DOM ready)
    const saved = localStorage.getItem('theme');
    const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;

    if (saved === 'dark' || (!saved && prefersDark)) {
        document.documentElement.classList.add('dark-loading');
        console.log('Theme: Added dark-loading class');
    }
})();

// Apply theme to body when DOM is ready
document.addEventListener('DOMContentLoaded',function () {
    console.log('Theme: DOM ready, applying theme...');
    const saved = localStorage.getItem('theme');
    const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;

    if (saved === 'dark' || (!saved && prefersDark)) {
        document.body.classList.add('dark');
        console.log('Theme: Applied dark theme to body');
    }

    // Remove loading class from html
    document.documentElement.classList.remove('dark-loading');

    // Setup theme toggle button if exists (optional)
    const btn = document.getElementById('themeToggle');
    console.log('Theme: Theme button found:',!!btn);

    if (btn) {
        btn.addEventListener('click',function () {
            console.log('Theme: Toggle button clicked');
            document.body.classList.toggle('dark');
            const isDark = document.body.classList.contains('dark');
            localStorage.setItem('theme',isDark ? 'dark' : 'light');
            console.log('Theme: Switched to',isDark ? 'dark' : 'light','theme');
        });
        console.log('Theme: Event listener added to theme button');
    }
});