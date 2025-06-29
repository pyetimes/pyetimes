use axum::{Json, Router, extract::State, http::StatusCode, routing};
use zeroize::Zeroize;

use crate::{
    models::{Article, ArticleCreate, ErrorPayload},
    repo::{ArticlesRepo, AuthorsRepo},
    state::{self, AppState},
};

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/", routing::get(get))
        .route("/", routing::post(post))
}

async fn get(State(_state): State<AppState>) -> String {
    format!("Hello, world!").to_string()
}

async fn post(
    State(state): State<AppState>,
    Json(info): Json<ArticleCreate>,
) -> Result<Json<Article>, ErrorPayload> {
    let author =
        AuthorsRepo::validate_credentials(&state.db, &info.author.email, &info.author.password)
            .await;

    if author.is_err() {
        return Err(ErrorPayload::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            format!(
                "Error validating author credentials: {}",
                author.unwrap_err()
            ),
        ));
    }

    let author = author.unwrap();

    if author.is_none() {
        return Err(ErrorPayload::new(
            StatusCode::UNAUTHORIZED,
            "Invalid author credentials".to_string(),
        ));
    }

    let author = author.unwrap();

    let article = ArticlesRepo::create(&state.db, author.id, &info).await;

    if article.is_err() {
        return Err(ErrorPayload::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            format!("Error creating article: {}", article.unwrap_err()),
        ));
    }

    Ok(Json(article.unwrap()))
}
