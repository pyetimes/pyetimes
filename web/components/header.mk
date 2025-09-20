<header class="header">
    <div class="header-title">
        <div>
            <h1 class="masthead"><a href="/">PyE TIMES</a></h1>
            <p class="tagline">"Todas las Noticias que Merecen Compilar"</p>
        </div>
    </div>
    <div class="header-info">
        <div>
            <x-time></x-time>
            <br />
            <span>Dias sin Bugs: 0</span>
        </div>
        <button class="menu" onclick="toggleNav()"></button>
        <button class="theme-toggle" onclick="toggleTheme()"></button>
    </div>
    <nav id="navbar" class="navbar">
        <ul class="nav-links">
            <li><a href="/">Inicio</a></li>
            <li><a href="/about">Sobre Nosotros</a></li>
        </ul>
    </nav>
</header>
<script>
    function toggleNav() {
        const navbar = document.getElementById('navbar');
        navbar.classList.toggle('active');
    }

    function toggleTheme() {
        document.documentElement.classList.toggle('dark-theme');
        window.localStorage.setItem('theme', document.documentElement.classList.contains('dark-theme') ? 'dark' : 'light');
    }

    window.addEventListener('load', function() {
        const DARK_CLASS = 'dark-theme';
        const savedTheme = window.localStorage.getItem('theme');

        function setDarkMode(enabled) {
            document.documentElement.classList.toggle(DARK_CLASS, enabled);
        }

        if (savedTheme === null) {
            setDarkMode(window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches)
        } else {
            setDarkMode(savedTheme === 'dark'); 
        }

        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (event) => {
            if (window.localStorage.getItem('theme') !== null) return;
            setDarkMode(event.matches);
        });
    });
</script>