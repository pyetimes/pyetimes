use axum::Router;
use tower_http::services::{ServeDir, ServeFile};

use crate::state::AppState;

mod articles;
mod authors;
mod index;

pub fn routes() -> Router<AppState> {
    Router::new()
        .nest("/api/authors", authors::routes())
        .nest("/articles", articles::routes())
        .route("/health", axum::routing::get(health_check))
        .merge(index::routes())
        .nest_service("/css", ServeDir::new("static/css"))
        .nest_service("/js", ServeDir::new("static/js"))
        .nest_service("/images", ServeDir::new("static/images"))
        .nest_service("/favicon.png", ServeFile::new("static/favicon.png"))
}

async fn health_check() -> String {
    "Health check is working!".into()
}
