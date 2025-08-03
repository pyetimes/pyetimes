use magik_macro::template;

use crate::models;

#[template(path = "./web/pages/editor.mk")]
pub struct Editor<'a> {
    pub article: Option<&'a models::Article>,
    pub sections: &'a [models::Section],
}
