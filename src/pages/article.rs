use pulldown_cmark::{Parser, html};

use crate::{
    models::{Article, Author},
    pages::Page,
};

pub fn article(author: &Author, article: &Article) -> Page {
    let mut layout = magik::get("./pages/reader/layout.html");
    let mut article_template = magik::get("./pages/reader/article.html");

    article_template.set("title", &article.title);
    article_template.set("excerpt", &article.excerpt);
    article_template.set("author_name", &author.name);
    article_template.set(
        "published_at",
        &article
            .published_at
            .map_or(format!("Not published yet ({})", article.id), |date| {
                date.format(&"%d de %B, %Y").to_string()
            }),
    );

    let parser: Parser<'_> = Parser::new(&article.content);
    let mut html_content = String::new();

    html::push_html(&mut html_content, parser);

    article_template.set("content", &html_content);

    layout.set("body", &article_template);
    layout.into()
}
