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
                            Some(date) if props.article.published => format!("<x-time timestamp=\"{}\"></x-time>", date.and_utc().timestamp()),
                            _ => format!("No publicado aún ({}) <button id=\"publish-button\">Publicar</button>", props.article.id),
                        }
                    }}
                    </div>
                </article>

                <div class="article-content">{{ to_html(&props.article.content) }}</div>

                <!-- Comments Section -->
                {{
                    if props.article.published {
                        r#"<div class="comments-section">
                    <h3>Comentarios</h3>
                    
                    <div id="moderation-panel" style="display: none;">
                        <h4>Panel de Moderación</h4>
                        <div id="pending-comments"></div>
                    </div>
                    
                    <div id="approved-comments"></div>
                    
                    <div class="comment-form">
                        <h4>Deja tu comentario</h4>
                        <input type="text" id="comment-name" placeholder="Tu nombre" required />
                        <textarea id="comment-content" placeholder="Escribe tu comentario..." rows="4" required></textarea>
                        
                        <div class="captcha-container">
                            <img id="captcha-image" src="" alt="Captcha" />
                            <button id="refresh-captcha" type="button">🔄 Nuevo captcha</button>
                        </div>
                        <input type="text" id="captcha-answer" placeholder="Resultado de la operación" required />
                        
                        <button id="submit-comment" class="save-button">Enviar Comentario</button>
                    </div>
                </div>"#.to_string()
                    } else {
                        "".to_string()
                    }
                }}
            </div>
        </div>

        <style>
            .comments-section {
                margin-top: 60px;
                padding-top: 40px;
                border-top: 2px solid var(--color-border);
            }

            .comments-section h3 {
                font-size: 28px;
                margin-bottom: 30px;
            }

            .comment-form {
                background: var(--color-bg-secondary);
                padding: 30px;
                border-radius: 8px;
                margin-bottom: 40px;
            }

            .comment-form h4 {
                margin-top: 0;
                margin-bottom: 20px;
            }

            .comment-form input,
            .comment-form textarea {
                width: 100%;
                padding: 12px;
                margin-bottom: 15px;
                border: 1px solid var(--color-border);
                border-radius: 4px;
                background: var(--color-bg-primary);
                color: var(--color-text-primary);
                font-family: inherit;
                font-size: 14px;
            }

            .captcha-container {
                display: flex;
                align-items: center;
                gap: 10px;
                margin-bottom: 15px;
            }

            .captcha-container img {
                border: 1px solid var(--color-border);
                border-radius: 4px;
                background: white;
            }

            .captcha-container button {
                padding: 8px 16px;
                border: 1px solid var(--color-border);
                background: var(--color-bg-primary);
                color: var(--color-text-primary);
                border-radius: 4px;
                cursor: pointer;
            }

            .comment {
                background: var(--color-bg-secondary);
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 20px;
                border-left: 3px solid var(--color-accent);
            }

            .comment.pending {
                border-left-color: #f59e0b;
                opacity: 0.8;
            }

            .comment-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 10px;
            }

            .comment-author {
                font-weight: bold;
                color: var(--color-accent);
            }

            .comment-date {
                font-size: 12px;
                color: var(--color-text-secondary);
            }

            .comment-content {
                line-height: 1.6;
            }

            .comment-actions {
                margin-top: 15px;
                display: flex;
                gap: 10px;
            }

            .comment-actions button {
                padding: 6px 12px;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-size: 13px;
            }

            .approve-btn {
                background: #10b981;
                color: white;
            }

            .delete-btn {
                background: #ef4444;
                color: white;
            }

            #moderation-panel {
                background: #fff3cd;
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 30px;
                border: 2px solid #f59e0b;
            }

            #moderation-panel h4 {
                margin-top: 0;
                color: #856404;
            }
        </style>

        <dialog id="credentials-dialog">
            <div class="form">
                <input type="text" id="email" placeholder="Email" />
                <input type="password" id="password" placeholder="Contraseña" />
                <button id="save-button" class="save-button">Publicar</button>
            </div>
        </dialog>

        {{ Footer {} }}

        <script>
            const articleId = {{ props.article.id }};
            const articleAuthorId = {{ props.article.author_id }};
            let captchaToken = null;
            
            document.addEventListener("DOMContentLoaded", () => {
                // Check if user is the author
                const currentUser = localStorage.getItem('currentUser');
                const isAuthor = currentUser && JSON.parse(currentUser).id === articleAuthorId;
                
                if (isAuthor) {
                    document.getElementById('moderation-panel').style.display = 'block';
                    loadPendingComments();
                }
                
                // Load approved comments
                loadApprovedComments();
                
                // Load captcha
                loadCaptcha();
                
                // Refresh captcha button
                document.getElementById('refresh-captcha')?.addEventListener('click', loadCaptcha);
                
                // Submit comment
                document.getElementById('submit-comment')?.addEventListener('click', submitComment);
                
                {{ props.article.published.choose("", "setupPublishButton();") }}
            });

            async function loadCaptcha() {
                try {
                    const response = await fetch('/api/comments/captcha');
                    const data = await response.json();
                    captchaToken = data.token;
                    document.getElementById('captcha-image').src = 'data:image/svg+xml;base64,' + data.image_base64;
                } catch (error) {
                    console.error('Error loading captcha:', error);
                }
            }

            async function submitComment() {
                const name = document.getElementById('comment-name').value.trim();
                const content = document.getElementById('comment-content').value.trim();
                const answer = document.getElementById('captcha-answer').value.trim();
                
                if (!name || !content || !answer) {
                    alert('Por favor, completa todos los campos');
                    return;
                }
                
                try {
                    const response = await fetch('/api/comments', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            article_id: articleId,
                            author_name: name,
                            content: content,
                            captcha_token: captchaToken,
                            captcha_solution: answer
                        })
                    });
                    
                    if (response.ok) {
                        alert('¡Comentario enviado! Será visible una vez que sea aprobado.');
                        document.getElementById('comment-name').value = '';
                        document.getElementById('comment-content').value = '';
                        document.getElementById('captcha-answer').value = '';
                        loadCaptcha();
                    } else {
                        const error = await response.text();
                        alert('Error: ' + error);
                        loadCaptcha();
                    }
                } catch (error) {
                    alert('Error al enviar comentario: ' + error.message);
                }
            }

            async function loadApprovedComments() {
                try {
                    const response = await fetch(`/api/comments/article/${articleId}`);
                    const comments = await response.json();
                    
                    const container = document.getElementById('approved-comments');
                    if (comments.length === 0) {
                        container.innerHTML = '<p style="color: var(--color-text-secondary);">No hay comentarios aún. ¡Sé el primero en comentar!</p>';
                        return;
                    }
                    
                    container.innerHTML = comments.map(comment => `
                        <div class="comment">
                            <div class="comment-header">
                                <span class="comment-author">${comment.author_name}</span>
                                <span class="comment-date">${new Date(comment.created_at).toLocaleDateString('es-ES')}</span>
                            </div>
                            <div class="comment-content">${comment.content}</div>
                        </div>
                    `).join('');
                } catch (error) {
                    console.error('Error loading comments:', error);
                }
            }

            async function loadPendingComments() {
                try {
                    const response = await fetch('/api/comments/pending');
                    const comments = await response.json();
                    
                    const container = document.getElementById('pending-comments');
                    if (comments.length === 0) {
                        container.innerHTML = '<p style="color: #856404;">No hay comentarios pendientes de moderación.</p>';
                        return;
                    }
                    
                    container.innerHTML = comments
                        .filter(c => c.article_id === articleId)
                        .map(comment => `
                        <div class="comment pending">
                            <div class="comment-header">
                                <span class="comment-author">${comment.author_name} (Pendiente)</span>
                                <span class="comment-date">${new Date(comment.created_at).toLocaleDateString('es-ES')}</span>
                            </div>
                            <div class="comment-content">${comment.content}</div>
                            <div class="comment-actions">
                                <button class="approve-btn" onclick="approveComment(${comment.id})">✓ Aprobar</button>
                                <button class="delete-btn" onclick="deleteComment(${comment.id})">✗ Rechazar</button>
                            </div>
                        </div>
                    `).join('');
                } catch (error) {
                    console.error('Error loading pending comments:', error);
                }
            }

            async function approveComment(commentId) {
                try {
                    const response = await fetch(`/api/comments/${commentId}/approve`, {
                        method: 'POST'
                    });
                    
                    if (response.ok) {
                        alert('Comentario aprobado');
                        loadPendingComments();
                        loadApprovedComments();
                    } else {
                        alert('Error al aprobar comentario');
                    }
                } catch (error) {
                    alert('Error: ' + error.message);
                }
            }

            async function deleteComment(commentId) {
                if (!confirm('¿Estás seguro de que quieres eliminar este comentario?')) {
                    return;
                }
                
                try {
                    const response = await fetch(`/api/comments/${commentId}`, {
                        method: 'DELETE'
                    });
                    
                    if (response.ok) {
                        alert('Comentario eliminado');
                        loadPendingComments();
                        loadApprovedComments();
                    } else {
                        alert('Error al eliminar comentario');
                    }
                } catch (error) {
                    alert('Error: ' + error.message);
                }
            }

            function setupPublishButton() {
                const publishButton = document.getElementById("publish-button");
                const dialog = document.getElementById("credentials-dialog");
                const saveButton = document.getElementById("save-button");

                if (!publishButton) return;

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
            }
        </script>
    </body>
</html>