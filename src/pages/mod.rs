use axum::response::IntoResponse;
use magik::Template;

mod article;
mod editor;
mod index;
mod not_found;

pub use article::article;
pub use editor::editor;
pub use index::index;
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
