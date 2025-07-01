use axum::Router;

use crate::state::AppState;

mod articles;
mod authors;
mod index;

pub fn routes() -> Router<AppState> {
    Router::new()
        .nest("/api/authors", authors::routes())
        .nest("/articles", articles::routes())
        .merge(index::routes())
}
