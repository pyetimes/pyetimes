use axum::extract::{Path, Query};
use axum::{Router, extract::State, routing::get};
use tower_http::services::{ServeDir, ServeFile};

use crate::pages::{self, Page};
use crate::repo::{ArticlesRepo, SectionsRepo};
use crate::state::AppState;

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/", get(index))
        .route("/editor", get(editor))
        .nest_service("/css", ServeDir::new("static/css"))
        .nest_service("/images", ServeDir::new("static/images"))
        .nest_service("/favicon.png", ServeFile::new("static/favicon.png"))
}

async fn index(State(state): State<AppState>) -> Page {
    let feed = SectionsRepo::get_feed(&state.db)
        .await
        .unwrap_or_else(|_| vec![]);

    pages::index(feed.as_slice())
}

#[derive(serde::Deserialize)]
pub struct GetParams {
    pub article: i32,
}

async fn editor(State(state): State<AppState>, id: Query<GetParams>) -> Page {
    let article = ArticlesRepo::get_by_id(&state.db, id.article).await;

    if article.is_err() {
        return pages::editor(None);
    }

    pages::editor(article.unwrap())
}
