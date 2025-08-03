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
    pub section_id: Option<i32>,
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

#[derive(Debug, Clone, Serialize)]
pub struct ArticleDiscordUpdate<'a> {
    pub title: &'a str,
    pub url: &'a str,
    pub description: &'a str,
    pub published: bool,
}
