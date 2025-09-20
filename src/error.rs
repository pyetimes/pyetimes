use std::borrow::Cow;
use thiserror::Error;
use axum::response::{IntoResponse, Response};
use reqwest::StatusCode;
use serde::Deserialize;

#[allow(dead_code)]
#[derive(Error, Debug)]
pub enum Error {
    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),
    #[error(
        "Failed to create database pool: {0}. Ensure the database is running and the connection string is correct."
    )]
    DatabaseConnection(sqlx::Error),

    #[error("Unauthorized")]
    Unauthorized,

    #[error(transparent)]
    DomainErrors(#[from] DomainErrors),
}

#[derive(Error, Debug)]
pub enum DomainErrors {
    #[error("Error fetching article")]
    FetchingArticle(sqlx::Error),
    
    #[error("You are not allowed to publish articles")]
    NotAllowedToPublish,

    #[error("You can only update your own articles")]
    NotOwner,

    #[error("Cannot update a published article")]
    CannotUpdatePublishedArticle,

    #[error("Error updating article")]
    UpdateError(sqlx::Error),

    #[error("Article with slug '{slug}' already exists")]
    ArticleAlreadyExists { slug: String },

    #[error("Error publishing article")]
    ErrorPublishingArticle(sqlx::Error),

    #[error("Error creating author")]
    CreatingAuthor(sqlx::Error),

    #[error("Error fetching author")]
    ErrorFetchingAuthor(sqlx::Error),

    #[error("Not found")]
    ResourceNotFound,
}

impl From<DomainErrors> for ProblemDetails<'_> {
    fn from(value: DomainErrors) -> Self {
        let message = format!("{value}");
        match value {
            DomainErrors::FetchingArticle(sqlx_error) => {
                tracing::error!("{message} {sqlx_error}");
                ProblemDetails {
                    title: Cow::Borrowed("Fetching Article Error"),
                    status: StatusCode::INTERNAL_SERVER_ERROR.as_u16(),
                    detail: Cow::Owned(message),
                }
            },
            DomainErrors::NotOwner => ProblemDetails {
                title: Cow::Borrowed("Not Owner"),
                status: StatusCode::FORBIDDEN.as_u16(),
                detail: Cow::Owned(message),
            },
            DomainErrors::CannotUpdatePublishedArticle => ProblemDetails {
                title: Cow::Borrowed("Cannot Update Published Article"),
                status: StatusCode::CONFLICT.as_u16(),
                detail: Cow::Owned(message),
            },
            DomainErrors::UpdateError(sqlx_error) => {
                tracing::error!("Error updating article {sqlx_error}");
                ProblemDetails {
                    title: Cow::Borrowed("Error Updating Article"),
                    status: StatusCode::INTERNAL_SERVER_ERROR.as_u16(),
                    detail: Cow::Owned(message),
                }
            }
            DomainErrors::ArticleAlreadyExists { .. } => {
                ProblemDetails {
                    title: Cow::Borrowed("Article Already Exists"),
                    status: StatusCode::CONFLICT.as_u16(),
                    detail: Cow::Owned(message),
                }
            }
            DomainErrors::NotAllowedToPublish => ProblemDetails {
                title: Cow::Borrowed("Not Allowed to Publish"),
                status: StatusCode::FORBIDDEN.as_u16(),
                detail: Cow::Owned(message),
            },
            DomainErrors::ErrorPublishingArticle(sqlx_error) => {
                tracing::error!("Error publishing article {sqlx_error}");
                ProblemDetails {
                    title: Cow::Borrowed("Error Publishing Article"),
                    status: StatusCode::INTERNAL_SERVER_ERROR.as_u16(),
                    detail: Cow::Owned(message),
                }
            },
            DomainErrors::CreatingAuthor(sqlx_error) => {
                tracing::error!("{message} {sqlx_error}");
                ProblemDetails {
                    title: Cow::Borrowed("Error Creating Author"),
                    status: StatusCode::INTERNAL_SERVER_ERROR.as_u16(),
                    detail: Cow::Owned(message),
                }
            },
            DomainErrors::ResourceNotFound => {
                tracing::info!("Resource not found");
                ProblemDetails {
                    title: Cow::Borrowed("Resource Not Found"),
                    status: StatusCode::NOT_FOUND.as_u16(),
                    detail: Cow::Owned(message),
                }
            }
            DomainErrors::ErrorFetchingAuthor(sqlx_error) => {
                tracing::error!("{message} {sqlx_error}");
                ProblemDetails {
                    title: Cow::Borrowed("Error Fetching Author"),
                    status: StatusCode::INTERNAL_SERVER_ERROR.as_u16(),
                    detail: Cow::Owned(message),
                }
            }
        }
    }
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
            Error::Database(err) | Error::DatabaseConnection(err) => ProblemDetails {
                title: Cow::Borrowed("Database Error"),
                status: StatusCode::INTERNAL_SERVER_ERROR.as_u16(),
                detail: Cow::Owned(err.to_string()),
            },
            Error::DomainErrors(v) => v.into(),
            Error::Unauthorized => ProblemDetails {
                title: Cow::Borrowed("Unauthorized"),
                status: StatusCode::UNAUTHORIZED.as_u16(),
                detail: Cow::Borrowed("You are not authorized to access this resource."),
            },
        }
    }
}

impl IntoResponse for ProblemDetails<'_> {
    fn into_response(self) -> Response {
        let body = serde_json::json!({
            "title": self.title,
            "status": self.status,
            "detail": self.detail,
        });

        (StatusCode::from_u16(self.status).unwrap_or(StatusCode::INTERNAL_SERVER_ERROR), axum::Json(body)).into_response()
    }
}

// impl IntoResponse for Error {
//     fn into_response(self) -> Response {
//         match self {
//             Error::Database(err) => {
//                 tracing::error!("Database error: {}", err);
//                 (StatusCode::INTERNAL_SERVER_ERROR, "Internal Server Error").into_response()
//             }
//             Error::DatabaseConnection(err) => {
//                 tracing::error!("Database error: {}", err);
//                 (StatusCode::INTERNAL_SERVER_ERROR, "Internal Server Error").into_response()
//             }
//             Error::Unauthorized => {
//                 tracing::info!("Unauthorized access");
//                 (StatusCode::UNAUTHORIZED, "Unauthorized").into_response()
//             }
//             Error::DomainErrors(e) => e.into_response(),
//         }
//     }
// }
