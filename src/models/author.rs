use serde::{Deserialize, Serialize};
use sqlx::{FromRow, types::chrono::NaiveDateTime};

#[derive(Debug, Clone, FromRow, Serialize, Deserialize)]
pub struct Author {
    pub id: i32,
    pub name: String,
    pub email: String,
    pub password_hash: String,
    pub bio: Option<String>,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}
