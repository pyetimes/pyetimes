use axum::{
    Router,
    http::{StatusCode, Uri},
    response::Html,
};
use magik::Renderable;
use tower_http::cors::{self, CorsLayer};

use crate::{
    error::ProblemDetails,
    state::AppState,
    web::{self, pages::NotFound},
};

mod articles;
mod authors;
mod comments;
mod search;
mod sections;

pub fn routes() -> Router<AppState> {
    #[cfg(debug_assertions)]
    let cors = CorsLayer::new()
        .allow_origin(tower_http::cors::Any)
        .allow_methods(cors::Any)
        .allow_headers(cors::Any);

    #[cfg(not(debug_assertions))]
    let cors = {
        let origin = std::env::var("CORS_ALLOWED_ORIGIN")
            .unwrap_or_else(|_| "https://pyetimes.com".to_string());
        CorsLayer::new()
            .allow_origin(cors::AllowOrigin::exact(
                origin.parse().expect("Invalid CORS_ALLOWED_ORIGIN URL"),
            ))
            .allow_methods(cors::Any)
            .allow_headers(cors::Any)
    };

    Router::new()
        .nest("/api/authors", authors::routes())
        .nest("/api/articles", articles::routes())
        .nest("/api/comments", comments::routes())
        .nest("/api/search", search::routes())
        .nest("/api/sections", sections::routes())
        .route("/api/authenticate", axum::routing::post(authors::login_handler))
        .route("/health", axum::routing::get(health_check))
        .route("/error", axum::routing::get(error))
        .layer(cors)
        .fallback(fallback_handler)
}

async fn health_check() -> String {
    "Health check is working!".into()
}

async fn fallback_handler(_uri: Uri) -> (StatusCode, Html<String>) {
    (StatusCode::NOT_FOUND, Html(NotFound {}.render()))
}

async fn error() -> Html<String> {
    Html(
        web::pages::Error {
            details: ProblemDetails::from(crate::error::DomainErrors::ResourceNotFound),
        }
        .render(),
    )
}
