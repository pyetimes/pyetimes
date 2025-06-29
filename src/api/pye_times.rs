use axum::{Router, extract::State, response::Html, routing::get};
use tower_http::services::{ServeDir, ServeFile};

use crate::state::AppState;

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/", get(index))
        .nest_service("/css", ServeDir::new("static/css"))
        .nest_service("/favicon.png", ServeFile::new("static/favicon.png"))
}

async fn index(State(_state): State<AppState>) -> Html<String> {
    let mut layout = magik::get("./pages/layout.html");

    let mut builder = magik::ContentBuilder::new();

    for i in 0..3 {
        let mut section = magik::get("./pages/section.html");
        section.set("header", &format!("Sección {}", i + 1));
        section.set("articles", "Hola");
        builder.add(section.render());
    }

    layout.set("sections", builder.build().as_str());
    Html(layout.render())
}
