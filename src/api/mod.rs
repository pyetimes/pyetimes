use axum::Router;

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
}

async fn health_check() -> String {
    "Health check is working!".into()
}
