use axum::Router;

use crate::state::AppState;

mod articles;
mod authors;
mod pye_times;

pub fn routes() -> Router<AppState> {
    Router::new()
        .nest("/api/authors", authors::routes())
        .nest("/api/articles", articles::routes())
        .merge(pye_times::routes())
}
