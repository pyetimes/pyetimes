{{
    use pulldown_cmark::{Parser, html};
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
                        if let Some(date) = props.article.published_at {
                            format!("<x-time datetime=\"{}\"></x-time>", date.and_utc().timestamp())
                        } else {
                            format!("No publicado aún ({})", props.article.id)
                        }
                    }}</div>
                </article>

                <div class="article-content">{{ 
                    let parser: Parser<'_> = Parser::new(&props.article.content);
                    let mut html_content = String::new();
                    html::push_html(&mut html_content, parser);

                    html_content
                }}</div>
                </div>
            </div>
        </div>

        {{ Footer {} }}
    </body>
</html>