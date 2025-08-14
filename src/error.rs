use std::borrow::Cow;

use axum::response::{IntoResponse, Response};
use reqwest::StatusCode;
use serde::Deserialize;

#[allow(dead_code)]
#[derive(thiserror::Error, Debug)]
pub enum Error {
    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),

    #[error("Not found")]
    NotFound,

    #[error("Unauthorized")]
    Unauthorized,
}

#[derive(Debug, Clone, Deserialize)]
pub struct ProblemDetails<'a> {
    pub title: Cow<'a, str>,
    pub status: u16,
    pub detail: Cow<'a, str>,
}

impl From<Error> for ProblemDetails<'_> {
    fn from(error: Error) -> Self {
        match error {
            Error::Database(err) => ProblemDetails {
                title: Cow::Borrowed("Database Error"),
                status: StatusCode::INTERNAL_SERVER_ERROR.as_u16(),
                detail: Cow::Owned(err.to_string()),
            },
            Error::NotFound => ProblemDetails {
                title: Cow::Borrowed("Not Found"),
                status: StatusCode::NOT_FOUND.as_u16(),
                detail: Cow::Borrowed("The requested resource was not found."),
            },
            Error::Unauthorized => ProblemDetails {
                title: Cow::Borrowed("Unauthorized"),
                status: StatusCode::UNAUTHORIZED.as_u16(),
                detail: Cow::Borrowed("You are not authorized to access this resource."),
            },
        }
    }
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
