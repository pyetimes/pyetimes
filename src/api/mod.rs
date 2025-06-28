use axum::Router;

use crate::state::AppState;

mod authors;
mod pye_times;

pub fn routes() -> Router<AppState> {
    Router::new()
        .nest("/authors", authors::routes())
        .merge(pye_times::routes())
}
