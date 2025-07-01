use axum::http::{StatusCode, Uri};

use crate::pages::{self, Page};

pub async fn fallback_handler(_uri: Uri) -> (StatusCode, Page) {
    (StatusCode::NOT_FOUND, pages::not_found())
}
