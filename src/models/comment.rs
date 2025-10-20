use serde::{Deserialize, Serialize};
use sqlx::{FromRow, types::chrono::NaiveDateTime};

#[derive(Debug, Clone, FromRow, Serialize, Deserialize)]
pub struct Comment {
    pub id: i32,
    pub article_id: i32,
    pub author_name: String,
    pub content: String,
    pub captcha_token: String,
    pub approved: bool,
    pub created_at: NaiveDateTime,
    pub approved_at: Option<NaiveDateTime>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct CommentCreate {
    pub article_id: i32,
    pub author_name: String,
    pub content: String,
    pub captcha_token: String,
    pub captcha_solution: String,
}

#[derive(Debug, Clone, FromRow, Serialize)]
pub struct CaptchaToken {
    pub id: i32,
    pub token: String,
    pub solution: String,
    pub created_at: NaiveDateTime,
    pub used: bool,
    pub expires_at: NaiveDateTime,
}

#[derive(Debug, Clone, Serialize)]
pub struct CaptchaResponse {
    pub token: String,
    pub image_base64: String,
}
