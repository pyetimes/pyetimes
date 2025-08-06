{{
    use crate::web::components::{ 
        MainArticle,
        Meta,
        Header,
        Footer,
        Section,
        ArticlePreview
    };
}}
<!DOCTYPE html>
<html>
    <head>
        {{ Meta::default() }}
        
        <!-- Styles -->
        <link rel="stylesheet" href="/css/global.css" />
        <link rel="stylesheet" href="/css/layout.css" />

        <!-- Scripts -->
        <script src="/js/web_components.js"></script>
    </head>
    <body>
        <div class="main-wrapper">
            {{ Header {} }}

            <div class="container">
                <div class="main-grid">{{
                    if let Some((article, author)) = &props.main_story {
                        MainArticle {
                            headline: article.title.as_str(),
                            slug: article.slug.as_str(),
                            author_name: author.name.as_str(),
                            date: article.published_at,
                            lead_text: article.excerpt.as_str(),
                        }.render()
                    }
                    else {
                        "".render()
                    }
                }}</div>
                <div class="section-grid">{{
                    props.sections.iter().map(|section| Section {
                        title: section.title.as_str(),
                        articles: section.articles.iter().map(|article| ArticlePreview {
                            title: article.title.as_str(),
                            slug: article.slug.as_str(),
                            excerpt: article.excerpt.as_str(),
                            author: props.authors.get(&article.author_id).map(|a| a.name.as_str()).unwrap_or("Unknown"),
                            date: article.published_at.unwrap_or_default(),
                        }).collect(),
                    }).collect::<Vec<Section>>()
                }}</div>
            </div>
        </div>

        {{ Footer {} }}
    </body>
</html>