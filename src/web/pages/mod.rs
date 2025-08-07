mod editor;

use std::collections::HashMap;

use magik_macro::template;

use crate::models;
pub use editor::Editor;

#[template(path = "./web/pages/index.mk")]
pub struct Index {
    pub main_story: Option<(models::Article, models::Author)>,
    pub sections: Vec<models::Section>,
    pub authors: HashMap<i32, models::Author>,
}

#[template(path = "./web/pages/404.mk")]
pub struct NotFound {}

#[template(path = "./web/pages/article.mk")]
pub struct Article<'a> {
    pub article: &'a models::Article,
    pub author: &'a models::Author,
}

#[template(path = "./web/pages/register.mk")]
pub struct Register {}

#[template(path = "./web/pages/about.mk")]
pub struct About {}

#[template(path = "./web/pages/error.mk")]
pub struct Error {}
