use axum::{
    Json, Router,
    extract::{Path, State},
    http::StatusCode,
    routing,
};

use crate::{
    models::{Article, ArticleCreate, AuthorCredentials, ErrorPayload},
    repo::ArticlesRepo,
    state::AppState,
    utils::{auth::validate_user_required, discord},
};

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/", routing::post(post))
        .route("/{id}/publish", routing::post(publish)) // Temporalmente comentado
}

async fn post(
    State(state): State<AppState>,
    Json(info): Json<ArticleCreate>,
) -> Result<Json<Article>, ErrorPayload> {
    let author =
        validate_user_required(&state.db, &info.author.email, &info.author.password).await?;

    let article = ArticlesRepo::get_by_slug(&state.db, &info.slug).await;

    let Ok(article) = article else {
        return Err(ErrorPayload::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            format!(
                "Error checking for existing article: {}",
                article.unwrap_err()
            ),
        ));
    };

    let section = if info.section < 0 {
        None
    } else {
        Some(info.section)
    };

    if let Some(article) = article {
        if article.author_id != author.id {
            return Err(ErrorPayload::new(
                StatusCode::FORBIDDEN,
                "You can only update your own articles".to_string(),
            ));
        }

        if article.published {
            return Err(ErrorPayload::new(
                StatusCode::CONFLICT,
                "Cannot update a published article".to_string(),
            ));
        }

        let article = ArticlesRepo::update(
            &state.db,
            &info.slug, // assuming slug is used as id for this example
            &info.title,
            &info.content,
            &info.tags,
            &info.excerpt,
            section,
        )
        .await;

        if let Err(err) = article {
            return Err(ErrorPayload::new(
                StatusCode::INTERNAL_SERVER_ERROR,
                format!("Error updating article: {}", err),
            ));
        }

        return Ok(Json(article.unwrap()));
    }

    let article = ArticlesRepo::create(&state.db, author.id, &info).await;

    if let Err(sqlx::Error::Database(db_err)) = article {
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

    let article = article.unwrap();

    if let Some(discord_bot) = &state.discord_bot {
        tokio::spawn(discord::notify_discord_bot(
            discord_bot.clone(),
            article.clone(),
        ));
    }

    Ok(Json(article))
}

#[derive(serde::Serialize)]
struct SuccessResponse {
    message: String,
}

async fn publish(
    State(state): State<AppState>,
    Path(id): Path<i32>,
    Json(credentials): Json<AuthorCredentials>,
) -> Result<Json<SuccessResponse>, ErrorPayload> {
    let author =
        validate_user_required(&state.db, &credentials.email, &credentials.password).await?;

    if !author.can_publish {
        return Err(ErrorPayload::new(
            StatusCode::FORBIDDEN,
            "You are not allowed to publish articles".to_string(),
        ));
    }

    let article = ArticlesRepo::publish(&state.db, id).await;

    if article.is_err() {
        return Err(ErrorPayload::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            "Error publishing article".to_string(),
        ));
    }

    if let Some(discord_bot) = &state.discord_bot {
        tokio::spawn(discord::notify_discord_bot(
            discord_bot.clone(),
            article.unwrap(),
        ));
    }

    Ok(Json(SuccessResponse {
        message: "Article published successfully".to_string(),
    }))
}
