use axum::{Router, extract::State, routing::get};
use tower_http::services::{ServeDir, ServeFile};

use crate::pages::{self, Page};
use crate::repo::SectionsRepo;
use crate::state::AppState;

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/", get(index))
        .route("/editor", get(editor))
        .nest_service("/css", ServeDir::new("static/css"))
        .nest_service("/favicon.png", ServeFile::new("static/favicon.png"))
}

async fn index(State(state): State<AppState>) -> Page {
    let feed = SectionsRepo::get_feed(&state.db)
        .await
        .unwrap_or_else(|_| vec![]);

    pages::index(feed.as_slice())
}

async fn editor(State(_state): State<AppState>) -> Page {
    pages::editor()
}
