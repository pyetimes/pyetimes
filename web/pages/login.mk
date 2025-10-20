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
                title: "Iniciar Sesión - PyE Times",
                description: "Inicia sesión en PyE Times para gestionar tus artículos.",
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
                <div class="auth-container">
                    <h2 class="editor-title">Iniciar Sesión</h2>
                    <p class="auth-subtitle">Accede a tu cuenta para gestionar tus artículos</p>
                    
                    <div class="form">
                        <div class="form-group">
                            <label for="email">Correo Electrónico</label>
                            <input type="email" id="email" placeholder="tu@email.com" autocomplete="email" required />
                        </div>
                        
                        <div class="form-group">
                            <label for="password">Contraseña</label>
                            <input type="password" id="password" placeholder="Tu contraseña" autocomplete="current-password" required />
                        </div>

                        <button id="login-button" class="save-button">Iniciar Sesión</button>
                        
                        <div class="auth-links">
                            <p>¿No tienes cuenta? <a href="/register">Regístrate aquí</a></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                function validateEmail(email) {
                    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    return re.test(String(email).toLowerCase());
                }

                // Check if already logged in
                const currentUser = localStorage.getItem('currentUser');
                if (currentUser) {
                    window.location.href = '/profile';
                    return;
                }

                const loginButton = document.getElementById("login-button");
                const emailInput = document.getElementById("email");
                const passwordInput = document.getElementById("password");

                // Handle Enter key
                [emailInput, passwordInput].forEach(input => {
                    input.addEventListener("keypress", (e) => {
                        if (e.key === "Enter") {
                            loginButton.click();
                        }
                    });
                });

                loginButton.addEventListener("click", async () => {
                    loginButton.disabled = true;
                    loginButton.textContent = "Iniciando sesión...";

                    const email = emailInput.value.trim();
                    const password = passwordInput.value;

                    if (!email || !password) {
                        alert("Por favor, completa todos los campos.");
                        loginButton.disabled = false;
                        loginButton.textContent = "Iniciar Sesión";
                        return;
                    }

                    if (!validateEmail(email)) {
                        alert("Por favor, ingresa un correo electrónico válido.");
                        loginButton.disabled = false;
                        loginButton.textContent = "Iniciar Sesión";
                        return;
                    }

                    try {
                        // Authenticate with backend
                        const response = await fetch("/api/authenticate", {
                            method: "POST",
                            headers: {
                                "Content-Type": "application/json",
                            },
                            body: JSON.stringify({ email, password }),
                        });
                        
                        if (!response.ok) {
                            if (response.status === 401) {
                                throw new Error("Credenciales incorrectas. Verifica tu email y contraseña.");
                            }
                            const errorData = await response.json();
                            throw new Error(errorData.detail || "Error al iniciar sesión");
                        }

                        const data = await response.json();
                        const author = data.author;

                        // Store user session
                        const userSession = {
                            id: author.id,
                            name: author.name,
                            email: author.email,
                            bio: author.bio || "",
                            can_publish: author.can_publish || false,
                            profile_image: author.profile_image || "",
                            password: password, // Store for API calls (needed for article creation)
                            loginTime: new Date().toISOString()
                        };

                        localStorage.setItem('currentUser', JSON.stringify(userSession));
                        
                        alert("¡Bienvenido, " + author.name + "!");
                        window.location.href = '/profile';

                    } catch (error) {
                        alert("Error al iniciar sesión: " + error.message);
                        loginButton.disabled = false;
                        loginButton.textContent = "Iniciar Sesión";
                    }
                });
            });
        </script>

        {{ Footer {} }}
    </body>
</html>
