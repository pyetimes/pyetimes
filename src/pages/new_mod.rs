use magik_macro::template;

use crate::models::{Article, Author, Section};

#[template(path = "./web/pages/index.tmp")]
pub struct Index {
    pub main_story: Option<(Article, Author)>,
    pub sections: Vec<Section>,
}
