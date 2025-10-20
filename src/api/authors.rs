use axum::{
    Json, Router,
    extract::{Path, State},
    routing::{get, post},
};

use crate::{
    error::{DomainErrors, ProblemDetails}, 
    models::{Author, AuthorCreate, AuthorCredentials}, 
    repo::AuthorsRepo, 
    state::AppState,
    utils::auth::validate_user,
};

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/", get(get_authors).post(post_author))
        .route("/{id}", get(get_author_by_id))
}

async fn get_authors(State(state): State<AppState>) -> Json<Vec<Author>> {
    let list = AuthorsRepo::get_all(&state.db).await.unwrap_or_default();

    Json(list)
}

async fn post_author(
    State(state): State<AppState>,
    Json(author): Json<AuthorCreate>,
) -> Result<Json<Author>, ProblemDetails<'static>> {
    let author = AuthorsRepo::create(&state.db, &author).await.map_err(DomainErrors::CreatingAuthor)?;

    Ok(Json(author))
}

async fn get_author_by_id(
    State(state): State<AppState>,
    Path(id): axum::extract::Path<i32>,
) -> Result<Json<Author>, ProblemDetails<'static>> {
    let author = AuthorsRepo::get_by_id(&state.db, id).await.map_err(DomainErrors::ErrorFetchingAuthor)?;

    match author {
        Some(author) => Ok(Json(author)),
        None => Err(DomainErrors::ResourceNotFound)?
    }
}

#[derive(serde::Serialize)]
pub struct LoginResponse {
    pub author: Author,
    pub message: String,
}

pub async fn login_handler(
    State(state): State<AppState>,
    Json(credentials): Json<AuthorCredentials>,
) -> Result<Json<LoginResponse>, ProblemDetails<'static>> {
    tracing::info!("Login attempt for email: {}", credentials.email);
    
    let author = validate_user(&state.db, &credentials.email, &credentials.password)
        .await?;

    tracing::info!("Login successful for user: {}", author.name);

    Ok(Json(LoginResponse {
        author,
        message: "Login successful".to_string(),
    }))
}
