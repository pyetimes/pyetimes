use axum::response::{IntoResponse, Response};
use reqwest::StatusCode;
use thiserror::Error;

#[allow(dead_code)]
#[derive(Error, Debug)]
pub enum Error {
    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),

    #[error("Not found")]
    NotFound,

    #[error("Unauthorized")]
    Unauthorized,
}

impl IntoResponse for Error {
    fn into_response(self) -> Response {
        match self {
            Error::Database(err) => {
                tracing::error!("Database error: {}", err);
                (StatusCode::INTERNAL_SERVER_ERROR, "Internal Server Error").into_response()
            }
            Error::NotFound => {
                tracing::info!("Resource not found");
                (StatusCode::NOT_FOUND, "Not Found").into_response()
            }
            Error::Unauthorized => {
                tracing::info!("Unauthorized access");
                (StatusCode::UNAUTHORIZED, "Unauthorized").into_response()
            }
        }
    }
}
