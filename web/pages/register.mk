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
                title: "Registrar Autor - PyE Times",
                description: "Formulario para registrar un nuevo autor en el sistema.",
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
                    <h2 class="editor-title">Registro de Autor</h2>
                    <p class="auth-subtitle">Crea tu cuenta para comenzar a escribir en PyE Times</p>
                    
                    <div class="form">
                        <div class="form-group">
                            <label for="name">Nombre Completo *</label>
                            <input type="text" id="name" placeholder="Tu nombre completo" autocomplete="name" required />
                            <span class="input-help">Este nombre aparecerá en tus artículos</span>
                        </div>
                        
                        <div class="form-group">
                            <label for="bio">Biografía</label>
                            <textarea id="bio" placeholder="Cuéntanos sobre ti, tus intereses y experiencia..." rows="4"></textarea>
                            <span class="input-help">Opcional - Puedes completarlo después en tu perfil</span>
                        </div>
                        
                        <div class="form-group">
                            <label for="email">Correo Electrónico *</label>
                            <input type="email" id="email" placeholder="tu@email.com" autocomplete="email" required />
                            <span class="input-help">Usarás este email para iniciar sesión</span>
                        </div>
                        
                        <div class="form-group">
                            <label for="password">Contraseña *</label>
                            <input type="password" id="password" placeholder="Mínimo 6 caracteres" autocomplete="new-password" required />
                            <div id="password-strength" class="password-strength"></div>
                        </div>

                        <div class="form-group">
                            <label for="confirm-password">Confirmar Contraseña *</label>
                            <input type="password" id="confirm-password" placeholder="Confirma tu contraseña" autocomplete="new-password" required />
                        </div>

                        <button id="register-button" class="save-button">Registrarse</button>
                        
                        <div class="auth-links">
                            <p>¿Ya tienes cuenta? <a href="/login">Inicia sesión aquí</a></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <style>
            .auth-container {
                max-width: 600px;
                margin: 40px auto;
            }

            .auth-subtitle {
                color: var(--color-text-secondary);
                text-align: center;
                margin: -10px 0 30px 0;
            }

            .input-help {
                display: block;
                font-size: 13px;
                color: var(--color-text-secondary);
                margin-top: 5px;
            }

            .password-strength {
                height: 4px;
                border-radius: 2px;
                margin-top: 8px;
                transition: all 0.3s;
            }

            .password-weak {
                background: linear-gradient(90deg, #ef4444 33%, #e5e7eb 33%);
            }

            .password-medium {
                background: linear-gradient(90deg, #f59e0b 66%, #e5e7eb 66%);
            }

            .password-strong {
                background: #10b981;
            }

            .auth-links {
                margin-top: 20px;
                text-align: center;
                color: var(--color-text-secondary);
            }

            .auth-links a {
                color: var(--color-accent);
                text-decoration: none;
            }

            .auth-links a:hover {
                text-decoration: underline;
            }
        </style>
        
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                // Check if already logged in
                const currentUser = localStorage.getItem('currentUser');
                if (currentUser) {
                    window.location.href = '/profile';
                    return;
                }

                function validateEmail(email) {
                    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    return re.test(String(email).toLowerCase());
                }

                function getPasswordStrength(password) {
                    if (password.length === 0) return 0;
                    if (password.length < 6) return 1; // weak
                    
                    let strength = 1;
                    if (password.length >= 8) strength++;
                    if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
                    if (/\d/.test(password)) strength++;
                    if (/[^a-zA-Z\d]/.test(password)) strength++;
                    
                    return Math.min(strength, 3); // max 3
                }

                const registerButton = document.getElementById("register-button");
                const passwordInput = document.getElementById("password");
                const confirmPasswordInput = document.getElementById("confirm-password");
                const passwordStrength = document.getElementById("password-strength");

                // Password strength indicator
                passwordInput.addEventListener("input", () => {
                    const strength = getPasswordStrength(passwordInput.value);
                    passwordStrength.className = 'password-strength';
                    
                    if (strength === 1) {
                        passwordStrength.classList.add('password-weak');
                    } else if (strength === 2) {
                        passwordStrength.classList.add('password-medium');
                    } else if (strength === 3) {
                        passwordStrength.classList.add('password-strong');
                    }
                });

                // Handle Enter key
                const inputs = [
                    document.getElementById("name"),
                    document.getElementById("bio"),
                    document.getElementById("email"),
                    passwordInput,
                    confirmPasswordInput
                ];

                inputs.forEach(input => {
                    input.addEventListener("keypress", (e) => {
                        if (e.key === "Enter") {
                            registerButton.click();
                        }
                    });
                });

                registerButton.addEventListener("click", async () => {
                    registerButton.disabled = true;
                    registerButton.textContent = "Registrando...";

                    const name = document.getElementById("name").value.trim();
                    const bio = document.getElementById("bio").value.trim();
                    const email = document.getElementById("email").value.trim();
                    const password = passwordInput.value;
                    const confirmPassword = confirmPasswordInput.value;

                    // Validation
                    if (!name || !email || !password) {
                        alert("Por favor, completa todos los campos obligatorios (*).");
                        registerButton.disabled = false;
                        registerButton.textContent = "Registrarse";
                        return;
                    }

                    if (name.length < 3) {
                        alert("El nombre debe tener al menos 3 caracteres.");
                        registerButton.disabled = false;
                        registerButton.textContent = "Registrarse";
                        return;
                    }

                    if (!validateEmail(email)) {
                        alert("Por favor, ingresa un correo electrónico válido.");
                        registerButton.disabled = false;
                        registerButton.textContent = "Registrarse";
                        return;
                    }

                    if (password.length < 6) {
                        alert("La contraseña debe tener al menos 6 caracteres.");
                        registerButton.disabled = false;
                        registerButton.textContent = "Registrarse";
                        return;
                    }

                    if (password !== confirmPassword) {
                        alert("Las contraseñas no coinciden. Por favor, verifica.");
                        registerButton.disabled = false;
                        registerButton.textContent = "Registrarse";
                        return;
                    }

                    const author = {
                        name,
                        bio: bio || null,
                        email,
                        password,
                        can_publish: false,
                    };

                    try {
                        const response = await fetch("/api/authors", {
                            method: "POST",
                            headers: {
                                "Content-Type": "application/json",
                            },
                            body: JSON.stringify(author),
                        });

                        if (!response.ok) {
                            const errorText = await response.text();
                            
                            // Handle specific errors
                            if (errorText.includes("duplicate key") || errorText.includes("already exists")) {
                                throw new Error("Este email ya está registrado. Intenta con otro o inicia sesión.");
                            }
                            
                            throw new Error(errorText || "Error al registrar el autor");
                        }

                        const createdAuthor = await response.json();
                        
                        alert("¡Registro exitoso! Bienvenido, " + name + "!");
                        
                        // Auto-login after registration
                        const userSession = {
                            id: createdAuthor.id,
                            name: createdAuthor.name,
                            email: createdAuthor.email,
                            bio: createdAuthor.bio || "",
                            can_publish: createdAuthor.can_publish || false,
                            profile_image: createdAuthor.profile_image || "",
                            password: password,
                            loginTime: new Date().toISOString()
                        };

                        localStorage.setItem('currentUser', JSON.stringify(userSession));
                        window.location.href = "/profile";

                    } catch (error) {
                        alert("Error al registrar: " + error.message);
                        registerButton.disabled = false;
                        registerButton.textContent = "Registrarse";
                    }
                });
            });
        </script>

        {{ Footer {} }}
    </body>
</html>