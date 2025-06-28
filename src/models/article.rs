use sqlx::{FromRow, types::chrono::NaiveDateTime};

#[derive(Debug, Clone, FromRow)]
pub struct Article {
    pub id: i32,
    pub title: String,
    pub content: String,
    pub author_id: i32,
    pub published: bool,
    pub tags: Vec<String>,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}
