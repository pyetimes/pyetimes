use axum::{http::StatusCode, response::IntoResponse};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ErrorPayload {
    #[serde(skip)]
    pub status: StatusCode,
    pub error: String,
}

impl ErrorPayload {
    pub fn new(status: StatusCode, error: String) -> Self {
        Self { status, error }
    }
}

impl IntoResponse for ErrorPayload {
    fn into_response(self) -> axum::response::Response {
        let header = (
            axum::http::header::CONTENT_TYPE,
            "text/plain; charset=utf-8",
        );
        let body = self.error;

        let mut response = axum::response::Response::new(body.into());
        *response.status_mut() = self.status;
        response
            .headers_mut()
            .insert(header.0, header.1.parse().unwrap());
        response
    }
}
