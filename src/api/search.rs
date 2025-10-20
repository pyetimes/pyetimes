use axum::{
    Json, Router,
    extract::{Query, State},
    routing::get,
};
use serde::Deserialize;

use crate::{
    error::{DomainErrors, ProblemDetails},
    models::Article,
    repo::SearchRepo,
    state::AppState,
};

#[derive(Debug, Deserialize)]
pub struct SearchQuery {
    pub q: String,
    #[serde(default = "default_limit")]
    pub limit: i64,
    #[serde(default)]
    pub offset: i64,
}

fn default_limit() -> i64 {
    20
}

#[derive(Debug, Deserialize)]
pub struct PaginationQuery {
    #[serde(default = "default_limit")]
    pub limit: i64,
    #[serde(default)]
    pub offset: i64,
}

#[derive(serde::Serialize)]
pub struct SearchResponse {
    pub articles: Vec<Article>,
    pub total: i64,
    pub limit: i64,
    pub offset: i64,
}

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/", get(search_articles))
        .route("/section/{id}", get(get_by_section))
        .route("/tag/{tag}", get(get_by_tag))
}

async fn search_articles(
    State(state): State<AppState>,
    Query(query): Query<SearchQuery>,
) -> Result<Json<SearchResponse>, ProblemDetails<'static>> {
    if query.q.trim().is_empty() {
        return Err(ProblemDetails {
            title: std::borrow::Cow::Borrowed("Validation Error"),
            status: 400,
            detail: std::borrow::Cow::Borrowed("Search query cannot be empty"),
        });
    }
    
    let articles = SearchRepo::search_articles(&state.db, &query.q, query.limit, query.offset)
        .await
        .map_err(|e| {
            tracing::error!("Error searching articles: {}", e);
            DomainErrors::ResourceNotFound
        })?;
    
    let total = SearchRepo::count_search_results(&state.db, &query.q)
        .await
        .unwrap_or(0);
    
    Ok(Json(SearchResponse {
        articles,
        total,
        limit: query.limit,
        offset: query.offset,
    }))
}

async fn get_by_section(
    State(state): State<AppState>,
    axum::extract::Path(id): axum::extract::Path<i32>,
    Query(query): Query<PaginationQuery>,
) -> Result<Json<Vec<Article>>, ProblemDetails<'static>> {
    let articles = SearchRepo::get_articles_by_section(&state.db, id, query.limit, query.offset)
        .await
        .map_err(|e| {
            tracing::error!("Error fetching articles by section: {}", e);
            DomainErrors::ResourceNotFound
        })?;
    
    Ok(Json(articles))
}

async fn get_by_tag(
    State(state): State<AppState>,
    axum::extract::Path(tag): axum::extract::Path<String>,
    Query(query): Query<PaginationQuery>,
) -> Result<Json<Vec<Article>>, ProblemDetails<'static>> {
    let articles = SearchRepo::get_articles_by_tag(&state.db, &tag, query.limit, query.offset)
        .await
        .map_err(|e| {
            tracing::error!("Error fetching articles by tag: {}", e);
            DomainErrors::ResourceNotFound
        })?;
    
    Ok(Json(articles))
}
