use axum::response::IntoResponse;
use magik_old::Template;

mod editor;
mod new_mod;

pub use editor::editor;
pub use new_mod::*;

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
