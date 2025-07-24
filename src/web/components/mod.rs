use chrono::NaiveDateTime;
use magik_macro::template;

#[template(path = "./web/components/article.tmp")]
pub struct Article<'a> {
    pub title: &'a str,
    pub content: &'a str,
}

#[template(path = "./web/components/main_article.tmp")]
pub struct MainArticle<'a> {
    pub id: i32,
    pub headline: &'a str,
    pub slug: &'a str,
    pub author_name: &'a str,
    pub date: Option<NaiveDateTime>,
    pub lead_text: &'a str,
}

#[template(path = "./web/components/meta.tmp")]
pub struct Meta {}

#[template(path = "./web/components/header.tmp")]
pub struct Header {}

#[template(path = "./web/components/footer.tmp")]
pub struct Footer {}

#[template(path = "./web/components/section.tmp")]
pub struct Section<'a, 'b> {
    pub title: &'a str,
    pub articles: Vec<ArticlePreview<'b>>,
}

#[template(path = "./web/components/article_preview.tmp")]
pub struct ArticlePreview<'a> {
    pub title: &'a str,
    pub slug: &'a str,
    pub excerpt: &'a str,
}
