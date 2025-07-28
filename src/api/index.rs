use axum::extract::Query;
use axum::response::Html;
use axum::{Router, extract::State, routing::get};
use magik::Renderable;

use crate::pages;
use crate::repo::{ArticlesRepo, FeedRepo};
use crate::state::AppState;

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/", get(index))
        .route("/editor", get(editor))
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

#[derive(serde::Deserialize)]
pub struct GetParams {
    pub article: Option<i32>,
}

async fn editor(State(state): State<AppState>, id: Query<GetParams>) -> Html<String> {
    if id.article.is_none() {
        return Html(pages::Editor { article: None }.render());
    }

    let article = ArticlesRepo::get_by_id(&state.db, id.article.unwrap()).await;

    if article.is_err() {
        return Html(pages::Editor { article: None }.render());
    }

    let article = article.unwrap();

    if let Some(article) = article {
        return Html(
            pages::Editor {
                article: Some(&article),
            }
            .render(),
        );
    }

    Html(pages::Editor { article: None }.render())
}
