use serde::{Deserialize, Serialize};
use sqlx::{FromRow, types::chrono::NaiveDateTime};

#[derive(Debug, Clone, FromRow, Serialize, Deserialize)]
pub struct Author {
    pub id: i32,
    pub name: String,
    pub email: String,
    #[serde(skip_serializing)]
    pub password_hash: String,
    pub bio: Option<String>,
    pub created_at: NaiveDateTime,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthorCreate {
    pub name: String,
    pub email: String,
    pub password: String,
    pub bio: Option<String>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct AuthorCredentials {
    pub email: String,
    pub password: String,
}
