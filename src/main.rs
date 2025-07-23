use tower_http::trace::TraceLayer;

mod api;
mod db;
mod error;
mod models;
mod pages;
mod repo;
mod state;
mod web;

#[tokio::main(flavor = "current_thread")]
async fn main() {
    println!("Starting PyE TIMES server...");

    // Create tracing subscriber
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::DEBUG)
        .init();

    dotenv::dotenv().ok();

    let app_sate = state::AppState {
        db: db::create_pool().await.map_err(|e| {
            panic!(
                "Failed to create database pool: {}. Ensure the database is running and the connection string is correct.",
                e
            )
        }).unwrap(),
    };

    let app = api::routes()
        .with_state(app_sate)
        .layer(TraceLayer::new_for_http())
        .fallback(error::fallback_handler);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();

    println!("Listening on http://localhost:3000");

    axum::serve(listener, app).await.unwrap();
}
