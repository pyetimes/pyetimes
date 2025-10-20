{{
    use serde_json::json;
    use pulldown_cmark::{Parser, html};
    use crate::web::components::{ 
        Meta,
        Header,
        Footer,
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
        href="/css/toastui-editor.min.css"
        />
        
        <!-- Scripts -->
        <script src="/js/toastui-editor-all.min.js"></script>
        <script src="/js/web_components.js"></script>
    </head>
    <body>
        <div class="main-wrapper">
            {{ Header {} }}

            <div class="container">
                <h2 class="editor-title">
                    {{
                        if props.article.is_some() {
                            "Editar Artículo"
                        } else {
                            "Crear Nuevo Artículo"
                        }
                    }}
                </h2>
                <br/>
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
                <div style="display: flex; gap: 10px">
                    <input
                        type="text"
                        id="tags"
                        placeholder="Etiquetas (separadas por comas)"
                        value="{{ props.article.map_or("".to_string(), |a| a.tags.join(", ")) }}"
                    />
                    <select id="section">
                        <option value="-1">Sección: Ninguna</option>
                        {{
                            let selected_section = props.article.and_then(|a| a.section_id);

                            props.sections.iter().map(
                                |section| format!(
                                    "<option value=\"{}\" {}>Sección: {}</option>", 
                                    section.id,
                                    (Some(section.id) == selected_section).choose("selected", ""),
                                    section.title)
                            ).collect::<String>()
                        }}
                    </select>
                </div>
                
                <div id="editor"></div>

                <div class="form">
                    <div id="auth-info" class="auth-info" style="display: none;">
                        <p>Sesión iniciada como: <strong id="current-user-name"></strong></p>
                    </div>
                    <button id="save-button" class="save-button">{{
                        props.article.map_or("Crear Artículo".to_string(), |_| "Actualizar Artículo".to_string())
                    }}</button>
                </div>
            </div>
        </div>

        <style>
            .auth-info {
                background: var(--color-bg-secondary);
                padding: 12px 16px;
                border-radius: 4px;
                margin-bottom: 15px;
                border-left: 3px solid var(--color-accent);
            }

            .auth-info p {
                margin: 0;
                color: var(--color-text-secondary);
            }

            .auth-info strong {
                color: var(--color-text-primary);
            }
        </style>
        
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                // Check authentication
                const currentUser = localStorage.getItem('currentUser');
                if (!currentUser) {
                    alert("Debes iniciar sesión para crear o editar artículos");
                    window.location.href = '/login';
                    return;
                }

                const user = JSON.parse(currentUser);

                // Display current user info
                document.getElementById('current-user-name').textContent = user.name;
                document.getElementById('auth-info').style.display = 'block';

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
                    editor.setMarkdown("");
                    saveButton.textContent = "Actualizar Artículo";
                }

                saveButton.addEventListener("click", () => {
                    // disable button to prevent multiple clicks
                    saveButton.disabled = true;
                    saveButton.textContent = "Guardando...";

                    const markdown = editor.getMarkdown();
                    let data = {
                        title: document.getElementById("title").value.trim(),
                        slug: document.getElementById("slug").value.trim(),
                        excerpt: document.getElementById("excerpt").value.trim(),
                        tags: document
                        .getElementById("tags")
                        .value.split(",")
                        .map((tag) => tag.trim().toLowerCase())
                        .filter(tag => tag.length > 0), // split tags by comma and trim whitespace
                        content: markdown,
                        author: {
                            email: user.email,
                            password: user.password,
                        },
                        section: parseInt(document.getElementById("section").value, 10),
                    };

                    if (
                        !data.title ||
                        !data.slug ||
                        !data.excerpt ||
                        !data.content
                    ) {
                        alert("Por favor, completa todos los campos (título, slug, extracto y contenido).");
                        saveButton.disabled = false;
                        saveButton.textContent = document.getElementById("title").value ? "Actualizar Artículo" : "Crear Artículo";
                        return;
                    }

                    if (!validateSlug(data.slug)) {
                        alert(
                            "El slug solo puede contener letras, números, guiones y guiones bajos."
                        );
                        saveButton.disabled = false;
                        saveButton.textContent = document.getElementById("title").value ? "Actualizar Artículo" : "Crear Artículo";
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
                            const errorText = await response.text();
                            throw new Error(errorText);
                        }
                        
                        const result = await response.json();
                        alert("¡Artículo guardado exitosamente!");
                        
                        let redirectUrl = "/drafts/" + result.slug;
                        window.location.href = redirectUrl;
                    })
                    .catch((error) => {
                        alert("Error al guardar el artículo: " + error.message);
                        saveButton.disabled = false;
                        saveButton.textContent = document.getElementById("title").value ? "Actualizar Artículo" : "Crear Artículo";
                    });
                });
            });
        </script>

        {{ Footer {} }}
    </body>
</html>