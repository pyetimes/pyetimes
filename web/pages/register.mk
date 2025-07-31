{{
    use crate::web::components::{ 
        Meta,
        Header,
        Footer,
        EditorHeader,
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
            {{ EditorHeader {} }}

            <div class="container">
                <div class="form">
                    <input type="text" id="name" placeholder="Nombre" />
                    <textarea id="bio" placeholder="Biografía"></textarea>
                    <input type="text" id="email" placeholder="Email" />
                    <input type="password" id="password" placeholder="Contraseña" />
                    <button id="save-button" class="save-button">Registrar</button>
                </div>
            </div>
        </div>
        
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                function validateEmail(email) {
                    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    return re.test(String(email).toLowerCase());
                }

                function cleanAllInputs() {
                    document.getElementById("name").value = "";
                    document.getElementById("email").value = "";
                    document.getElementById("password").value = "";
                    document.getElementById("bio").value = "";
                }

                const saveButton = document.getElementById("save-button");

                saveButton.addEventListener("click", () => {
                    // disable button to prevent multiple clicks
                    saveButton.disabled = true;

                    let data = {
                        name: document.getElementById("name").value,
                        email: document.getElementById("email").value,
                        password: document.getElementById("password").value,
                        bio: document.getElementById("bio").value,
                    };

                    if (
                        !data.name ||
                        !data.email ||
                        !data.password
                    ) {
                        alert("Por favor, completa todos los campos obligatorios (nombre, email, contraseña).");
                        saveButton.disabled = false;
                        return;
                    }

                    if (!validateEmail(data.email)) {
                        alert("Por favor, ingresa un correo electrónico válido.");
                        saveButton.disabled = false;
                        return;
                    }

                    // Send data to the server
                    fetch("/api/authors", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                        },
                        body: JSON.stringify(data),
                    })
                    .then(async (response) => {
                        if (!response.ok) {
                            alert(await response.text());
                            return;
                        }
                        alert(
                            "Autor creado exitosamente! ID: " +
                            (await response.json()).id
                        );
                        cleanAllInputs();
                    })
                    .catch((error) => {
                        alert("Error al guardar el autor: " + error.message);
                    })
                    .finally(() => {
                        // re-enable button after request
                        saveButton.disabled = false;
                    });
                });
            });
        </script>

        {{ Footer {} }}
    </body>
</html>