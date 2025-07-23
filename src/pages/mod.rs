use axum::response::IntoResponse;
use magik_old::Template;

mod article;
mod editor;
mod index;
mod new_mod;
mod not_found;

pub use article::article;
pub use editor::editor;
pub use new_mod::*;
pub use not_found::not_found;

pub struct Page {
    tmp: Template,
}

impl IntoResponse for Page {
    fn into_response(self) -> axum::response::Response {
        let rendered = self.tmp.render();
        axum::response::Html(rendered).into_response()
    }
}

impl Into<Page> for Template {
    fn into(self) -> Page {
        Page { tmp: self }
    }
}
