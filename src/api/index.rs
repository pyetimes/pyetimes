use axum::extract::Query;
use axum::{Router, extract::State, routing::get};
use tower_http::services::{ServeDir, ServeFile};

use crate::pages::{self, Page};
use crate::repo::{ArticlesRepo, FeedRepo};
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
    let feed = FeedRepo::get(&state.db).await;

    if feed.is_err() {
        return pages::index(None, &[]);
    }

    let (main_story, sections) = feed.unwrap();

    pages::index(main_story, sections.as_slice())
}

#[derive(serde::Deserialize)]
pub struct GetParams {
    pub article: Option<i32>,
}

async fn editor(State(state): State<AppState>, id: Query<GetParams>) -> Page {
    if id.article.is_none() {
        return pages::editor(None);
    }

    let article = ArticlesRepo::get_by_id(&state.db, id.article.unwrap()).await;

    if article.is_err() {
        return pages::editor(None);
    }

    pages::editor(article.unwrap())
}
