use axum::extract::Query;
use axum::response::Html;
use axum::{Router, extract::State, routing::get};
use magik::Renderable;

use crate::pages;
use crate::repo::ArticlesRepo;
use crate::state::AppState;

pub fn routes() -> Router<AppState> {
    Router::new().route("/", get(editor))
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
