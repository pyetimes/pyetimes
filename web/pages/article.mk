{{
    use crate::utils::markdown::to_html;
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
                title: &props.article.title,
                description: &props.article.excerpt,
                ..Default::default()
            }
        }}
        
        <!-- Styles -->
        <link rel="stylesheet" href="/css/global.css" />
        <link rel="stylesheet" href="/css/layout.css" />
        <link rel="stylesheet" href="/css/article.css" />
        <link rel="stylesheet" href="/css/markdown.css" />
        <link rel="stylesheet" href="/css/editor.css" />
        
        <!-- Scripts -->
        <script src="/js/web_components.js"></script>
    </head>
    <body>
        <div class="main-wrapper">
            {{ Header {} }}

            <div class="container">
                <br/>
                <div class="article-header-links">
                    <a href="/" class="back-link">← Volver al PyE Times</a>
                    {{
                        if props.article.published {
                            format!("<span class=\"tags\">{}<span>", props.article.tags
                                .iter()
                                .map(|tag| format!("<a class=\"tag-link\">{}</a>", tag))
                                .collect::<Vec<_>>()
                                .concat())
                        } else {
                            format!("<a href=\"/editor?article={}\" class=\"edit-link\">Editar</a>", props.article.id)
                        }
                    }}
                </div>

                <article class="article-header">
                    <h1 class="headline">{{ props.article.title }}</h1>
                    <h2 class="subheadline">{{ props.article.excerpt }}</h2>
                    <div class="byline">Por {{ props.author.name }}</div>
                    <div class="date-info">Publicado: {{
                        match props.article.published_at {
                            Some(date) if props.article.published => format!("<x-time datetime=\"{}\"></x-time>", date.and_utc().timestamp()),
                            _ => format!("No publicado aún ({}) <button id=\"publish-button\">Publicar</button>", props.article.id),
                        }
                    }}
                    </div>
                </article>

                <div class="article-content">{{ to_html(&props.article.content) }}</div>
                </div>
            </div>
        </div>

        <dialog id="credentials-dialog">
            <div class="form">
                <input type="text" id="email" placeholder="Email" />
                <input type="password" id="password" placeholder="Contraseña" />
                <button id="save-button" class="save-button">Publicar</button>
            </div>
        </dialog>

        {{ Footer {} }}

        <script>
            document.addEventListener("DOMContentLoaded", () => {
                const publishButton = document.getElementById("publish-button");
                const dialog = document.getElementById("credentials-dialog");
                const saveButton = document.getElementById("save-button");

                publishButton.addEventListener("click", () => {
                    dialog.showModal();
                });

                dialog.addEventListener("click", () => {
                    if (event.target === dialog) {
                        dialog.close();
                    }
                });
                
                saveButton.addEventListener("click", async () => {
                    const email = document.getElementById("email").value;
                    const password = document.getElementById("password").value;

                    const response = await fetch(`/api/articles/{{ props.article.id }}/publish`, {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json"
                        },
                        body: JSON.stringify({ email, password })
                    });

                    if (response.ok) {
                        dialog.close();
                        window.location.href = `/articles/{{ props.article.slug }}`;
                    } else {
                        alert("Error al publicar el artículo. Verifica tus credenciales.");
                    }
                });
            });
        </script>
    </body>
</html>