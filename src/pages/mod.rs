use std::collections::HashMap;

use axum::extract::{Path, Query};
use axum::http::StatusCode;
use axum::response::Html;
use axum::{Router, extract::State, routing::get};
use magik::Renderable;
use tokio::join;
use tracing::info;

use crate::middleware::CacheControlLayer;
use crate::models::ErrorPayload;
use crate::repo::{ArticlesRepo, AuthorsRepo, FeedRepo, SectionsRepo};
use crate::state::AppState;
use crate::web::pages;

pub fn routes() -> Router<AppState> {
    Router::new()
        .route(
            "/",
            get(index).layer(CacheControlLayer::with_lifespan(3600)),
        )
        .route(
            "/editor",
            get(editor).layer(CacheControlLayer::with_lifespan(3600)),
        )
        .route(
            "/articles/{slug}",
            get(published_article_page).layer(CacheControlLayer::with_lifespan(3600)),
        )
        .route("/drafts/{slug}", get(draft_article_page))
        .route("/register", get(register))
        .route(
            "/about",
            get(about).layer(CacheControlLayer::with_lifespan(3600)),
        )
}

async fn index(State(state): State<AppState>) -> Html<String> {
    match FeedRepo::get(&state.db).await {
        Ok((main_story, sections, authors)) => Html(
            pages::Index {
                main_story,
                sections,
                authors,
            }
            .render(),
        ),
        Err(e) => {
            info!("Error fetching feed: {}", e);
            Html(
                pages::Index {
                    main_story: None,
                    sections: Vec::new(),
                    authors: HashMap::new(),
                }
                .render(),
            )
        }
    }
}

#[derive(serde::Deserialize)]
pub struct GetParams {
    pub article: Option<i32>,
}

async fn editor(State(state): State<AppState>, id: Query<GetParams>) -> Html<String> {
    let (article, sections) = if let Some(article_id) = id.article {
        let (article, sections) = join!(
            ArticlesRepo::get_by_id(&state.db, article_id),
            SectionsRepo::get_sections_flat(&state.db)
        );

        (article.unwrap_or(None), sections.unwrap_or(Vec::new()))
    } else {
        (
            None,
            SectionsRepo::get_sections_flat(&state.db)
                .await
                .unwrap_or(Vec::new()),
        )
    };

    Html(
        pages::Editor {
            article: article.as_ref(),
            sections: &sections,
        }
        .render(),
    )
}

async fn published_article_page(
    State(state): State<AppState>,
    Path(slug): Path<String>,
) -> Result<Html<String>, ErrorPayload> {
    article_page_impl(state, slug, false).await
}

async fn draft_article_page(
    State(state): State<AppState>,
    Path(slug): Path<String>,
) -> Result<Html<String>, ErrorPayload> {
    article_page_impl(state, slug, true).await
}

async fn article_page_impl(
    state: AppState,
    slug: String,
    is_draft: bool,
) -> Result<Html<String>, ErrorPayload> {
    let article = match ArticlesRepo::get_by_slug(&state.db, &slug).await {
        Ok(Some(article)) => article,
        Ok(None) => {
            info!("Article with slug '{}' not found", slug);
            return Ok(Html(pages::NotFound {}.render()));
        }
        Err(e) => {
            info!("Error fetching article by slug '{}': {}", slug, e);
            return Ok(Html(pages::NotFound {}.render()));
        }
    };

    if is_draft == article.published {
        return Ok(Html(pages::NotFound {}.render()));
    }

    let author = match AuthorsRepo::get_by_id(&state.db, article.author_id).await {
        Ok(Some(author)) => author,
        Ok(None) => {
            info!(
                "Author with ID '{}' not found for article '{}'",
                article.author_id, slug
            );
            return Err(ErrorPayload::new(
                StatusCode::INTERNAL_SERVER_ERROR,
                "Author not found".to_string(),
            ));
        }
        Err(e) => {
            info!("Error fetching author for article '{}': {}", slug, e);
            return Err(ErrorPayload::new(
                StatusCode::INTERNAL_SERVER_ERROR,
                format!("Error fetching author: {}", e),
            ));
        }
    };

    Ok(Html(
        pages::Article {
            article: &article,
            author: &author,
        }
        .render(),
    ))
}

pub async fn register() -> Html<String> {
    Html(pages::Register {}.render())
}

pub async fn about() -> Html<String> {
    Html(pages::About {}.render())
}
