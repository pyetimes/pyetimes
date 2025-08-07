use axum::{
    Router,
    http::{StatusCode, Uri},
    response::Html,
};
use magik::Renderable;
use tower_http::cors::{self, CorsLayer};
use tower_http::services::{ServeDir, ServeFile};

use crate::{state::AppState, web::pages::NotFound};

mod articles;
mod authors;

pub fn routes() -> Router<AppState> {
    #[cfg(debug_assertions)]
    let cors = CorsLayer::new()
        .allow_origin(tower_http::cors::Any)
        .allow_methods(cors::Any)
        .allow_headers(cors::Any);

    #[cfg(not(debug_assertions))]
    let cors = CorsLayer::new()
        .allow_origin("https://pyetimes.com".parse().unwrap())
        .allow_methods(cors::Any)
        .allow_headers(cors::Any);

    Router::new()
        .nest("/api/authors", authors::routes())
        .nest("/api/articles", articles::routes())
        .route("/health", axum::routing::get(health_check))
        .nest_service("/css", ServeDir::new("web/static/css"))
        .nest_service("/js", ServeDir::new("web/static/js"))
        .nest_service("/images", ServeDir::new("web/static/images"))
        .nest_service("/favicon.png", ServeFile::new("web/static/favicon.png"))
        .layer(cors)
        .fallback(fallback_handler)
}

async fn health_check() -> String {
    "Health check is working!".into()
}

async fn fallback_handler(_uri: Uri) -> (StatusCode, Html<String>) {
    (StatusCode::NOT_FOUND, Html(NotFound {}.render()))
}
