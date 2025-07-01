use crate::{models::Section, pages::Page};

pub fn index(data: &[Section]) -> Page {
    let mut layout = magik::get("./pages/reader/layout.html");
    let section = magik::get("./pages/reader/section.html");
    let article = magik::get("./pages/reader/article_preview.html");

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
