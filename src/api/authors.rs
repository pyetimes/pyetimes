use axum::{
    Json, Router,
    extract::{Path, State},
    http::StatusCode,
    routing::{get, post},
};

use crate::{
    models::{Author, AuthorCreate, ErrorPayload},
    repo::AuthorsRepo,
    state::AppState,
};

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/", get(get_authors))
        .route("/", post(post_author))
        .route("/{id}", get(get_author_by_id))
}

async fn get_authors(State(state): State<AppState>) -> Json<Vec<Author>> {
    let list = AuthorsRepo::get_all(&state.db).await.unwrap_or_default();

    Json(list)
}

async fn post_author(
    State(state): State<AppState>,
    Json(author): Json<AuthorCreate>,
) -> Result<Json<Author>, ErrorPayload> {
    match AuthorsRepo::create(&state.db, &author).await {
        Ok(author) => Ok(Json(author)),
        Err(e) => Err(ErrorPayload::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            format!("Error creating author: {}", e),
        )),
    }
}

async fn get_author_by_id(
    State(state): State<AppState>,
    Path(id): axum::extract::Path<i32>,
) -> Result<Json<Author>, ErrorPayload> {
    match AuthorsRepo::get_by_id(&state.db, id).await {
        Ok(Some(author)) => Ok(Json(author)),
        Ok(None) => Err(ErrorPayload::new(
            StatusCode::NOT_FOUND,
            "Author not found".to_string(),
        )),
        Err(e) => Err(ErrorPayload::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            format!("Error fetching author: {}", e),
        )),
    }
}
