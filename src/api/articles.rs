use axum::{
    Json, Router,
    extract::{Path, State},
    http::StatusCode,
    routing,
};
use sqlx::Error;

use crate::{
    models::{Article, ArticleCreate, ErrorPayload},
    pages::{self, Page},
    repo::{ArticlesRepo, AuthorsRepo},
    state::AppState,
};

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/", routing::post(post))
        .route("/{title}", routing::get(get_by_title))
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

    if let Err(ref err) = article {
        if let sqlx::Error::Database(db_err) = &err {
            return match db_err.code() {
                Some(code) if code == "23505" => Err(ErrorPayload::new(
                    StatusCode::CONFLICT,
                    format!("Article with slug '{}' already exists", info.slug),
                )),
                _ => Err(ErrorPayload::new(
                    StatusCode::INTERNAL_SERVER_ERROR,
                    format!("Database error: {}", db_err),
                )),
            };
        }
    }

    Ok(Json(article.unwrap()))
}

async fn get_by_title(
    State(state): State<AppState>,
    Path(title): Path<String>,
) -> Result<Page, ErrorPayload> {
    let article = ArticlesRepo::get_by_slug(&state.db, &title).await;

    if article.is_err() {
        return Ok(pages::not_found());
    }

    let article = article.unwrap();

    let author = AuthorsRepo::get_by_id(&state.db, article.author_id).await;

    if author.is_err() {
        return Err(ErrorPayload::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            format!("Error fetching author: {}", author.unwrap_err()),
        ));
    }

    let author = author.unwrap();

    if author.is_none() {
        return Err(ErrorPayload::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            "Author not found".to_string(),
        ));
    }

    let author = author.unwrap();

    Ok(pages::article(&author, &article))
}
