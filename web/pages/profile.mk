{{
    use crate::web::components::{ 
        Meta,
        Header,
        Footer,
    };
}}
<!DOCTYPE html>
<html>
    <head>
        {{ 
            Meta {
                title: "Mi Perfil - PyE Times",
                description: "Gestiona tu perfil y artículos en PyE Times.",
                ..Default::default()
            }
        }}
        
        <!-- Styles -->
        <link rel="stylesheet" href="/css/global.css" />
        <link rel="stylesheet" href="/css/layout.css" />
        <link rel="stylesheet" href="/css/editor.css" />

        <!-- Scripts -->
        <script src="/js/web_components.js"></script>
    </head>
    <body>
        <div class="main-wrapper">
            {{ Header {} }}

            <div class="container">
                <div class="profile-container">
                    <div class="profile-header">
                        <div class="profile-avatar">
                            <span id="avatar-initials"></span>
                        </div>
                        <div class="profile-info">
                            <h2 id="profile-name" class="editor-title"></h2>
                            <p id="profile-email" class="profile-email"></p>
                            <span id="publish-badge" class="badge" style="display: none;">Can Publish</span>
                        </div>
                    </div>

                    <div class="profile-tabs">
                        <button class="tab-button active" data-tab="bio">Biografía</button>
                        <button class="tab-button" data-tab="articles">Mis Artículos</button>
                        <button class="tab-button" data-tab="settings">Configuración</button>
                    </div>

                    <!-- Bio Tab -->
                    <div id="tab-bio" class="tab-content active">
                        <div class="form">
                            <div class="form-group">
                                <label for="bio">Biografía</label>
                                <textarea id="bio" placeholder="Cuéntanos sobre ti..." rows="6"></textarea>
                            </div>
                            <button id="update-bio-button" class="save-button">Actualizar Biografía</button>
                        </div>
                    </div>

                    <!-- Articles Tab -->
                    <div id="tab-articles" class="tab-content">
                        <div class="articles-header">
                            <h3>Mis Artículos</h3>
                            <a href="/editor" class="save-button" style="text-decoration: none; display: inline-block; padding: 10px 20px;">
                                + Crear Nuevo Artículo
                            </a>
                        </div>
                        <div id="articles-list" class="articles-grid">
                            <p class="loading-message">Cargando artículos...</p>
                        </div>
                    </div>

                    <!-- Settings Tab -->
                    <div id="tab-settings" class="tab-content">
                        <div class="form">
                            <h3>Cambiar Contraseña</h3>
                            <div class="form-group">
                                <label for="current-password">Contraseña Actual</label>
                                <input type="password" id="current-password" placeholder="Tu contraseña actual" />
                            </div>
                            <div class="form-group">
                                <label for="new-password">Nueva Contraseña</label>
                                <input type="password" id="new-password" placeholder="Nueva contraseña" />
                            </div>
                            <div class="form-group">
                                <label for="confirm-password">Confirmar Contraseña</label>
                                <input type="password" id="confirm-password" placeholder="Confirma tu nueva contraseña" />
                            </div>
                            <button id="change-password-button" class="save-button">Cambiar Contraseña</button>
                            
                            <hr style="margin: 30px 0; border: none; border-top: 1px solid var(--color-border);" />
                            
                            <button id="logout-button" class="danger-button">Cerrar Sesión</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <style>
            .profile-container {
                max-width: 900px;
                margin: 0 auto;
            }

            .profile-header {
                display: flex;
                align-items: center;
                gap: 20px;
                margin-bottom: 30px;
                padding: 20px;
                background: var(--color-bg-secondary);
                border-radius: 8px;
            }

            .profile-avatar {
                width: 80px;
                height: 80px;
                border-radius: 50%;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 32px;
                font-weight: bold;
            }

            .profile-info {
                flex: 1;
            }

            .profile-email {
                color: var(--color-text-secondary);
                margin: 5px 0;
            }

            .badge {
                display: inline-block;
                padding: 4px 12px;
                background: #10b981;
                color: white;
                border-radius: 12px;
                font-size: 12px;
                font-weight: bold;
                margin-top: 8px;
            }

            .profile-tabs {
                display: flex;
                gap: 10px;
                margin-bottom: 30px;
                border-bottom: 2px solid var(--color-border);
            }

            .tab-button {
                padding: 12px 24px;
                background: none;
                border: none;
                border-bottom: 3px solid transparent;
                cursor: pointer;
                font-size: 16px;
                color: var(--color-text-secondary);
                transition: all 0.3s;
            }

            .tab-button:hover {
                color: var(--color-text-primary);
            }

            .tab-button.active {
                color: var(--color-accent);
                border-bottom-color: var(--color-accent);
            }

            .tab-content {
                display: none;
            }

            .tab-content.active {
                display: block;
            }

            .articles-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 20px;
            }

            .articles-grid {
                display: grid;
                gap: 20px;
            }

            .article-card {
                padding: 20px;
                background: var(--color-bg-secondary);
                border-radius: 8px;
                border: 1px solid var(--color-border);
                transition: transform 0.2s, box-shadow 0.2s;
            }

            .article-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            }

            .article-card h4 {
                margin: 0 0 10px 0;
                color: var(--color-text-primary);
            }

            .article-card p {
                color: var(--color-text-secondary);
                margin: 0 0 15px 0;
                font-size: 14px;
            }

            .article-meta {
                display: flex;
                gap: 15px;
                font-size: 13px;
                color: var(--color-text-secondary);
                margin-bottom: 15px;
            }

            .article-status {
                display: inline-block;
                padding: 4px 10px;
                border-radius: 4px;
                font-size: 12px;
                font-weight: bold;
            }

            .status-published {
                background: #10b981;
                color: white;
            }

            .status-draft {
                background: #f59e0b;
                color: white;
            }

            .article-actions {
                display: flex;
                gap: 10px;
            }

            .article-actions button,
            .article-actions a {
                flex: 1;
                padding: 8px 16px;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                text-decoration: none;
                text-align: center;
                font-size: 14px;
                transition: opacity 0.2s;
            }

            .article-actions button:hover,
            .article-actions a:hover {
                opacity: 0.8;
            }

            .btn-view {
                background: var(--color-accent);
                color: white;
            }

            .btn-edit {
                background: #3b82f6;
                color: white;
            }

            .btn-publish {
                background: #10b981;
                color: white;
            }

            .danger-button {
                background: #ef4444;
                color: white;
                padding: 12px 24px;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-size: 16px;
                transition: background 0.2s;
            }

            .danger-button:hover {
                background: #dc2626;
            }

            .loading-message {
                text-align: center;
                color: var(--color-text-secondary);
                padding: 40px 0;
            }
        </style>
        
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                // Check authentication
                const currentUser = localStorage.getItem('currentUser');
                if (!currentUser) {
                    alert("Debes iniciar sesión para ver tu perfil");
                    window.location.href = '/login';
                    return;
                }

                const user = JSON.parse(currentUser);

                // Display user info
                document.getElementById('profile-name').textContent = user.name;
                document.getElementById('profile-email').textContent = user.email;
                document.getElementById('bio').value = user.bio || '';
                
                // Avatar initials
                const initials = user.name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();
                document.getElementById('avatar-initials').textContent = initials;

                // Show publish badge if applicable
                if (user.can_publish) {
                    document.getElementById('publish-badge').style.display = 'inline-block';
                }

                // Tab switching
                const tabButtons = document.querySelectorAll('.tab-button');
                const tabContents = document.querySelectorAll('.tab-content');

                tabButtons.forEach(button => {
                    button.addEventListener('click', () => {
                        const tabName = button.getAttribute('data-tab');
                        
                        tabButtons.forEach(btn => btn.classList.remove('active'));
                        tabContents.forEach(content => content.classList.remove('active'));
                        
                        button.classList.add('active');
                        document.getElementById('tab-' + tabName).classList.add('active');

                        if (tabName === 'articles') {
                            loadArticles();
                        }
                    });
                });

                // Update bio
                document.getElementById('update-bio-button').addEventListener('click', async () => {
                    const bioText = document.getElementById('bio').value;
                    alert('Funcionalidad de actualización de biografía en desarrollo.\nPor ahora, los cambios se guardan localmente.');
                    
                    user.bio = bioText;
                    localStorage.setItem('currentUser', JSON.stringify(user));
                });

                // Load user's articles
                async function loadArticles() {
                    const articlesList = document.getElementById('articles-list');
                    articlesList.innerHTML = '<p class="loading-message">Cargando artículos...</p>';

                    try {
                        const response = await fetch(`/api/articles/author/${user.id}`);
                        if (!response.ok) {
                            throw new Error('No se pudieron cargar los artículos');
                        }

                        const articles = await response.json();

                        if (articles.length === 0) {
                            articlesList.innerHTML = `
                                <div class="article-card">
                                    <h4>No tienes artículos aún</h4>
                                    <p>Comienza a escribir tu primer artículo para PyE Times.</p>
                                    <div class="article-actions">
                                        <a href="/editor" class="btn-edit">Crear Primer Artículo</a>
                                    </div>
                                </div>
                            `;
                            return;
                        }

                        articlesList.innerHTML = articles.map(article => {
                            const statusClass = article.published ? 'status-published' : 'status-draft';
                            const statusText = article.published ? 'Publicado' : 'Borrador';
                            const publishedDate = article.published_at 
                                ? new Date(article.published_at).toLocaleDateString('es-ES')
                                : 'No publicado';

                            return `
                                <div class="article-card">
                                    <h4>${article.title}</h4>
                                    <p>${article.excerpt}</p>
                                    <div class="article-meta">
                                        <span class="article-status ${statusClass}">${statusText}</span>
                                        <span>📅 ${publishedDate}</span>
                                    </div>
                                    <div class="article-actions">
                                        ${article.published 
                                            ? `<a href="/articles/${article.slug}" class="btn-view">Ver Artículo</a>`
                                            : `<a href="/articles/${article.slug}" class="btn-view">Vista Previa</a>`
                                        }
                                        <a href="/editor?article=${article.id}" class="btn-edit">Editar</a>
                                    </div>
                                </div>
                            `;
                        }).join('');

                    } catch (error) {
                        console.error('Error loading articles:', error);
                        articlesList.innerHTML = '<p class="loading-message">Error al cargar artículos. Por favor, intenta de nuevo.</p>';
                    }
                }

                // Change password
                document.getElementById('change-password-button').addEventListener('click', () => {
                    const currentPassword = document.getElementById('current-password').value;
                    const newPassword = document.getElementById('new-password').value;
                    const confirmPassword = document.getElementById('confirm-password').value;

                    if (!currentPassword || !newPassword || !confirmPassword) {
                        alert('Por favor, completa todos los campos.');
                        return;
                    }

                    if (currentPassword !== user.password) {
                        alert('La contraseña actual es incorrecta.');
                        return;
                    }

                    if (newPassword !== confirmPassword) {
                        alert('Las contraseñas nuevas no coinciden.');
                        return;
                    }

                    if (newPassword.length < 6) {
                        alert('La contraseña debe tener al menos 6 caracteres.');
                        return;
                    }

                    alert('Funcionalidad de cambio de contraseña en desarrollo.\nPor ahora, los cambios se guardan localmente.');
                    
                    user.password = newPassword;
                    localStorage.setItem('currentUser', JSON.stringify(user));
                    
                    document.getElementById('current-password').value = '';
                    document.getElementById('new-password').value = '';
                    document.getElementById('confirm-password').value = '';
                });

                // Logout
                document.getElementById('logout-button').addEventListener('click', () => {
                    if (confirm('¿Estás seguro de que quieres cerrar sesión?')) {
                        localStorage.removeItem('currentUser');
                        alert('Sesión cerrada correctamente');
                        window.location.href = '/';
                    }
                });
            });
        </script>

        {{ Footer {} }}
    </body>
</html>
