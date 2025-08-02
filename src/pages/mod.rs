use axum::extract::{Path, Query};
use axum::http::StatusCode;
use axum::response::Html;
use axum::{Router, extract::State, routing::get};
use magik::Renderable;

use crate::middleware::CacheControlLayer;
use crate::models::ErrorPayload;
use crate::repo::{ArticlesRepo, AuthorsRepo, FeedRepo};
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
    let article = ArticlesRepo::get_by_slug(&state.db, &slug).await;

    if article.is_err() {
        return Err(ErrorPayload::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            format!("Error fetching article: {}", article.unwrap_err()),
        ));
    }

    let article = article.unwrap();

    if article.is_none() {
        return Ok(Html(pages::NotFound {}.render()));
    }

    let article = article.unwrap();

    if is_draft {
        if article.published {
            return Ok(Html(pages::NotFound {}.render()));
        }
    } else if !article.published {
        return Ok(Html(pages::NotFound {}.render()));
    }

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
