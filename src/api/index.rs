use axum::response::Html;
use axum::{Router, extract::State, routing::get};
use magik::Renderable;

use crate::pages;
use crate::repo::FeedRepo;
use crate::state::AppState;

pub fn routes() -> Router<AppState> {
    Router::new().route("/", get(index))
}

async fn index(State(state): State<AppState>) -> Html<String> {
    let feed = FeedRepo::get(&state.db).await;

    if feed.is_err() {
        return Html(
            pages::Index {
                main_story: None,
                sections: Vec::new(),
            }
            .render(),
        );
    }

    let (main_story, sections) = feed.unwrap();

    Html(
        pages::Index {
            main_story,
            sections,
        }
        .render(),
    )
}
