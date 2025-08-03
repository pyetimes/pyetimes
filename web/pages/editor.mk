{{
    use serde_json::json;
    use pulldown_cmark::{Parser, html};
    use crate::web::components::{ 
        Meta,
        Header,
        Footer,
        EditorHeader,
    };

    fn escape_string(s: &str) -> String {
        let escaped = json!(s).to_string();
        escaped.trim_matches('"').to_string()
    }
}}
<!DOCTYPE html>
<html>
    <head>
        {{ 
            Meta {
                title: if props.article.is_some() {
                    "Editar Artículo - PyE Times"
                } else {
                    "Crear Artículo - PyE Times"
                },
                description: "Crea o edita un artículo para PyE Times.",
                ..Default::default()
            }
        }}
        
        <!-- Styles -->
        <link rel="stylesheet" href="/css/global.css" />
        <link rel="stylesheet" href="/css/layout.css" />
        <link rel="stylesheet" href="/css/editor.css" />

        <!-- Toast UI Editor -->
        <link
        rel="stylesheet"
        href="https://uicdn.toast.com/editor/latest/toastui-editor.min.css"
        />
        
        <!-- Scripts -->
        <script src="https://uicdn.toast.com/editor/latest/toastui-editor-all.min.js"></script>
        <script src="/js/web_components.js"></script>
    </head>
    <body>
        <div class="main-wrapper">
            {{ EditorHeader {} }}

            <div class="container">
                <div style="display: flex; gap: 10px">
                <input
                    type="text"
                    id="title"
                    placeholder="Título del Artículo"
                    value="{{ props.article.map_or("".to_string(), |a| a.title.to_string()) }}"
                />
                <input
                    type="text"
                    id="slug"
                    placeholder="URL Amigable"
                    value="{{ props.article.map_or("".to_string(), |a| a.slug.to_string()) }}"
                />
                </div>
                <input
                    type="text"
                    id="excerpt"
                    placeholder="Extracto del Artículo"
                    value="{{ props.article.map_or("".to_string(), |a| a.excerpt.to_string()) }}"
                />
                <input
                    type="text"
                    id="tags"
                    placeholder="Etiquetas (separadas por comas)"
                    value="{{ props.article.map_or("".to_string(), |a| a.tags.join(", ")) }}"
                />
                
                <div id="editor"></div>

                <div class="form">
                    <input type="text" id="email" placeholder="Email" />
                    <input type="password" id="password" placeholder="Contraseña" />
                    <button id="save-button" class="save-button">{{
                        props.article.map_or("Crear Artículo".to_string(), |_| "Actualizar Artículo".to_string())
                    }}</button>
                </div>
            </div>
        </div>
        
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const editor = new toastui.Editor({
                    el: document.getElementById("editor"),
                    height: "700px",
                    initialEditType: "markdown", // o 'wysiwyg'
                    previewStyle: "tab", // o 'vertical'
                    initialValue: "{{ 
                        props.article.map_or(
                            "# Bienvenido al Editor de PyE Times\\n\\nEscribe tu artículo aquí...".to_string(), 
                            |a| escape_string(&a.content))
                    }}", // contenido inicial
                });

                function validateEmail(email) {
                    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    return re.test(String(email).toLowerCase());
                }

                function validateSlug(slug) {
                    const re = /^[a-zA-Z0-9-_]+$/;
                    return re.test(slug);
                }

                const saveButton = document.getElementById("save-button");

                function cleanAllInputs() {
                    document.getElementById("title").value = "";
                    document.getElementById("slug").value = "";
                    document.getElementById("excerpt").value = "";
                    document.getElementById("tags").value = "";
                    document.getElementById("email").value = "";
                    document.getElementById("password").value = "";
                    editor.setMarkdown("");
                    saveButton.textContent = "Actualizar Artículo";
                }

                saveButton.addEventListener("click", () => {
                    // disable button to prevent multiple clicks
                    saveButton.disabled = true;

                    const markdown = editor.getMarkdown();
                    let data = {
                        title: document.getElementById("title").value,
                        slug: document.getElementById("slug").value,
                        excerpt: document.getElementById("excerpt").value,
                        tags: document
                        .getElementById("tags")
                        .value.split(",")
                        .map((tag) => tag.trim().toLowerCase()), // split tags by comma and trim whitespace
                        content: markdown,
                        author: {
                            email: document.getElementById("email").value,
                            password: document.getElementById("password").value,
                        },
                    };

                    if (
                        !data.title ||
                        !data.slug ||
                        !data.excerpt ||
                        !data.content ||
                        !data.author.email ||
                        !data.author.password
                    ) {
                        alert("Por favor, completa todos los campos.");
                        saveButton.disabled = false;
                        return;
                    }

                    if (!validateSlug(data.slug)) {
                        alert(
                            "El slug solo puede contener letras, números, guiones y guiones bajos."
                        );
                        saveButton.disabled = false;
                        return;
                    }
                    
                    if (!validateEmail(data.author.email)) {
                        alert("Por favor, ingresa un correo electrónico válido.");
                        saveButton.disabled = false;
                        return;
                    }

                    // Send data to the server
                    fetch("/api/articles", {
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
                        
                        let redirectUrl = "/drafts/" + (await response.json()).slug;
                        window.location.href = redirectUrl;
                    })
                    .catch((error) => {
                        alert("Error al guardar el artículo: " + error.message);
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