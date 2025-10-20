use axum::{
    Json, Router,
    extract::State,
    routing::get,
};

use crate::{
    error::{DomainErrors, ProblemDetails},
    models::Section,
    repo::SectionsRepo,
    state::AppState,
};

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/", get(get_all_sections))
}

async fn get_all_sections(
    State(state): State<AppState>,
) -> Result<Json<Vec<Section>>, ProblemDetails<'static>> {
    let sections = SectionsRepo::get_sections_flat(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Error fetching sections: {}", e);
            DomainErrors::ResourceNotFound
        })?;
    
    Ok(Json(sections))
}
