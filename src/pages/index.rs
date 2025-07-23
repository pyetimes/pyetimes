use crate::{
    models::{Article, Author, Section},
    pages::Page,
};

pub fn index(main_story: Option<(Article, Author)>, data: &[Section]) -> Page {
    let mut layout = magik_old::get("./pages/reader/layout.html");
    let section = magik_old::get("./pages/reader/section.html");
    let article = magik_old::get("./pages/reader/article_preview.html");

    let mut main_story_template = magik_old::get("./pages/reader/main_story.html");

    if let Some(main_story_data) = main_story {
        let article = main_story_data.0;
        let author = main_story_data.1;

        main_story_template.set("headline", &article.title);
        main_story_template.set("author_name", &author.name);
        main_story_template.set(
            "date",
            &article
                .published_at
                .map_or(format!("Not published yet ({})", article.id), |date| {
                    date.format(&"%d de %B, %Y").to_string()
                }),
        );
        main_story_template.set("slug", &article.slug);
        main_story_template.set("lead_text", &article.excerpt);
        layout.set("main_story", &main_story_template);
    } else {
        layout.set("main_story", &());
    }

    let mut sections = vec![];

    for section_data in data {
        let mut section_template = section.clone();
        section_template.set("title", &section_data.title);

        let mut articles = vec![];
        for article_data in &section_data.articles {
            let mut article_template = article.clone();
            article_template.set("title", &article_data.title);
            article_template.set("slug", &article_data.slug);
            article_template.set("excerpt", &article_data.excerpt);
            articles.push(article_template.render());
        }

        if articles.is_empty() {
            section_template.set("articles", &"No articles available");
        } else {
            section_template.set("articles", &articles.join("\n"));
        }

        sections.push(section_template);
    }

    layout.set("body", &sections);
    layout.into()
}
