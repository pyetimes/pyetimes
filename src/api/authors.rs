use axum::{Json, Router, extract::State, routing::get};

use crate::{models::Author, repo::AuthorsRepo, state::AppState};

pub fn routes() -> Router<AppState> {
    Router::new().route("/", get(authors_list))
}

async fn authors_list(State(state): State<AppState>) -> Json<Vec<Author>> {
    let list = AuthorsRepo::get_all(&state.db).await.unwrap_or_default();

    Json(list)
}

async fn author_create(State(state): State<AppState>, Json(author): Json<Author>) -> Json<Author> {
    println!("Creating author: {:?}", author);

    Json(author)
}
