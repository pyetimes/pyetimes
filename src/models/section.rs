use serde::{Deserialize, Serialize};
use sqlx::prelude::FromRow;

use crate::models::Article;

#[derive(Debug, Clone, FromRow, Serialize, Deserialize)]
pub struct Section {
    pub id: i32,
    pub priority: i32,
    pub title: String,
    #[sqlx(skip)]
    pub articles: Vec<Article>,
}
