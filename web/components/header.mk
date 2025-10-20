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
            <li><a href="/search">Búsqueda</a></li>
            <li><a href="/about">Sobre Nosotros</a></li>
            <li id="nav-auth-links">
                <a href="/login" id="nav-login">Iniciar Sesión</a>
            </li>
            <li id="nav-profile-link" style="display: none;">
                <a href="/profile" id="nav-profile">Mi Perfil</a>
            </li>
        </ul>
    </nav>
</header>
<script>
    // Check authentication status
    (function() {
        const currentUser = localStorage.getItem('currentUser');
        const loginLink = document.getElementById('nav-login');
        const profileLink = document.getElementById('nav-profile-link');
        const authLinks = document.getElementById('nav-auth-links');
        
        if (currentUser) {
            const user = JSON.parse(currentUser);
            authLinks.style.display = 'none';
            profileLink.style.display = 'block';
            document.getElementById('nav-profile').textContent = user.name;
        }
    })();

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