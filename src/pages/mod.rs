use axum::Extension;
use axum::extract::{Path, Query};
use axum::http::StatusCode;
use axum::response::Html;
use axum::{Router, extract::State, routing::get};
use axum_response_cache::CacheLayer;
use magik::Renderable;
use tower::Layer;

use crate::models::ErrorPayload;
use crate::repo::{ArticlesRepo, AuthorsRepo, FeedRepo};
use crate::state::AppState;
use crate::web::pages;

#[derive(Clone, Debug)]
pub struct CacheControlLayer;

impl<S> Layer<S> for CacheControlLayer {
    type Service = CacheControlLayerMiddleware<S>;

    fn layer(&self, inner: S) -> Self::Service {
        CacheControlLayerMiddleware { inner }
    }
}

struct CacheControlLayerMiddleware<S> {
    inner: S,
}

#[derive(Clone, Debug)]
struct ArticleType {
    pub is_draft: bool,
}

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/", get(index).layer(CacheLayer::with_lifespan(3600)))
        .route(
            "/editor",
            get(editor).layer(CacheLayer::with_lifespan(3600)),
        )
        .route(
            "/articles/{slug}",
            get(article_page)
                .layer(Extension(ArticleType { is_draft: false }))
                .layer(CacheLayer::with_lifespan(3600)),
        )
        .route(
            "/drafts/{slug}",
            get(article_page).layer(Extension(ArticleType { is_draft: true })),
        )
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

async fn article_page(
    State(state): State<AppState>,
    Path(slug): Path<String>,
    Extension(article_type): Extension<ArticleType>,
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

    if article_type.is_draft {
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
