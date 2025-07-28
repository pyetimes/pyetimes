use chrono::NaiveDateTime;
use magik_macro::template;

#[template(path = "./web/components/main_article.mk")]
pub struct MainArticle<'a> {
    pub id: i32,
    pub headline: &'a str,
    pub slug: &'a str,
    pub author_name: &'a str,
    pub date: Option<NaiveDateTime>,
    pub lead_text: &'a str,
}

#[template(path = "./web/components/meta.mk")]
pub struct Meta {}

#[template(path = "./web/components/header.mk")]
pub struct Header {}

#[template(path = "./web/components/footer.mk")]
pub struct Footer {}

#[template(path = "./web/components/section.mk")]
pub struct Section<'a, 'b> {
    pub title: &'a str,
    pub articles: Vec<ArticlePreview<'b>>,
}

#[template(path = "./web/components/article_preview.mk")]
pub struct ArticlePreview<'a> {
    pub title: &'a str,
    pub slug: &'a str,
    pub excerpt: &'a str,
}
