use axum::{
    Json, Router,
    extract::{Path, State},
    routing::{get, post},
    http::StatusCode,
};
use std::sync::{Arc, Mutex};

use crate::{
    error::{DomainErrors, ProblemDetails},
    models::{Comment, CommentCreate, CaptchaResponse},
    repo::{CommentsRepo, CaptchaRepo},
    state::AppState,
    utils::captcha::{CaptchaGenerator, RateLimiter},
};

lazy_static::lazy_static! {
    static ref RATE_LIMITER: Arc<Mutex<RateLimiter>> = Arc::new(Mutex::new(RateLimiter::new(10, 300)));
}

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/", post(create_comment))
        .route("/article/{article_id}", get(get_comments_by_article))
        .route("/captcha", get(generate_captcha))
        .route("/pending", get(get_pending_comments))
        .route("/{id}/approve", post(approve_comment))
        .route("/{id}", axum::routing::delete(delete_comment))
}

async fn generate_captcha(
    State(state): State<AppState>,
) -> Result<Json<CaptchaResponse>, ProblemDetails<'static>> {
    let (token, solution, image_base64) = CaptchaGenerator::generate();
    
    CaptchaRepo::create(&state.db, &token, &solution, 10)
        .await
        .map_err(|e| {
            tracing::error!("Error creating captcha token: {}", e);
            DomainErrors::ResourceNotFound
        })?;
    
    Ok(Json(CaptchaResponse {
        token,
        image_base64,
    }))
}

async fn create_comment(
    State(state): State<AppState>,
    Json(comment): Json<CommentCreate>,
) -> Result<(StatusCode, Json<Comment>), ProblemDetails<'static>> {
    if comment.author_name.is_empty() || comment.content.is_empty() {
        return Err(ProblemDetails {
            title: std::borrow::Cow::Borrowed("Validation Error"),
            status: StatusCode::BAD_REQUEST.as_u16(),
            detail: std::borrow::Cow::Borrowed("Author name and content cannot be empty"),
        });
    }
    
    if comment.content.len() > 1000 {
        return Err(ProblemDetails {
            title: std::borrow::Cow::Borrowed("Validation Error"),
            status: StatusCode::BAD_REQUEST.as_u16(),
            detail: std::borrow::Cow::Borrowed("Comment content is too long (max 1000 characters)"),
        });
    }
    
    let is_valid = CaptchaRepo::validate(&state.db, &comment.captcha_token, &comment.captcha_solution)
        .await
        .map_err(|e| {
            tracing::error!("Error validating captcha: {}", e);
            ProblemDetails {
                title: std::borrow::Cow::Borrowed("Captcha Validation Error"),
                status: StatusCode::INTERNAL_SERVER_ERROR.as_u16(),
                detail: std::borrow::Cow::Borrowed("Failed to validate captcha"),
            }
        })?;
    
    if !is_valid {
        return Err(ProblemDetails {
            title: std::borrow::Cow::Borrowed("Invalid Captcha"),
            status: StatusCode::BAD_REQUEST.as_u16(),
            detail: std::borrow::Cow::Borrowed("Invalid or expired captcha"),
        });
    }
    
    let comment = CommentsRepo::create(&state.db, &comment)
        .await
        .map_err(|e| {
            tracing::error!("Error creating comment: {}", e);
            DomainErrors::ResourceNotFound
        })?;
    
    Ok((StatusCode::CREATED, Json(comment)))
}

async fn get_comments_by_article(
    State(state): State<AppState>,
    Path(article_id): Path<i32>,
) -> Result<Json<Vec<Comment>>, ProblemDetails<'static>> {
    let comments = CommentsRepo::get_by_article_id(&state.db, article_id)
        .await
        .map_err(|e| {
            tracing::error!("Error fetching comments: {}", e);
            DomainErrors::ResourceNotFound
        })?;
    
    Ok(Json(comments))
}

async fn get_pending_comments(
    State(state): State<AppState>,
) -> Result<Json<Vec<Comment>>, ProblemDetails<'static>> {
    let comments = CommentsRepo::get_pending(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Error fetching pending comments: {}", e);
            DomainErrors::ResourceNotFound
        })?;
    
    Ok(Json(comments))
}

async fn approve_comment(
    State(state): State<AppState>,
    Path(id): Path<i32>,
) -> Result<Json<Comment>, ProblemDetails<'static>> {
    let comment = CommentsRepo::approve(&state.db, id)
        .await
        .map_err(|e| {
            tracing::error!("Error approving comment: {}", e);
            DomainErrors::ResourceNotFound
        })?;
    
    Ok(Json(comment))
}

async fn delete_comment(
    State(state): State<AppState>,
    Path(id): Path<i32>,
) -> Result<StatusCode, ProblemDetails<'static>> {
    CommentsRepo::delete(&state.db, id)
        .await
        .map_err(|e| {
            tracing::error!("Error deleting comment: {}", e);
            DomainErrors::ResourceNotFound
        })?;
    
    Ok(StatusCode::NO_CONTENT)
}
