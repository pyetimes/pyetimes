use serde::{Deserialize, Serialize};
use sqlx::{FromRow, types::chrono::NaiveDateTime};

use crate::models::author::AuthorCredentials;

#[derive(Debug, Clone, FromRow, Serialize, Deserialize)]
pub struct Article {
    pub id: i32,
    pub title: String,
    pub slug: String,
    pub content: String,
    pub excerpt: String,
    pub author_id: i32,
    pub published: bool,
    pub published_at: Option<NaiveDateTime>,
    pub tags: Vec<String>,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

#[derive(Debug, Clone, Deserialize)]
pub struct ArticleCreate {
    pub title: String,
    pub slug: String,
    pub content: String,
    pub excerpt: String,
    pub tags: Vec<String>,
    pub author: AuthorCredentials,
}
