use tower_http::trace::TraceLayer;

mod api;
mod db;
mod error;
mod middleware;
mod models;
mod pages;
mod repo;
mod state;
mod utils;
mod web;

#[tokio::main(flavor = "current_thread")]
async fn main() {
    println!("Starting PyE TIMES server...");

    // Create tracing subscriber
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::DEBUG)
        .init();

    dotenv::dotenv().ok();

    // TODO: create a function to create AppState
    // and move this logic there
    // AppState::from_env() -> Result<AppState, Error>
    let app_sate = state::AppState {
        db: db::create_pool().await.map_err(|e| {
            panic!(
                "Failed to create database pool: {}. Ensure the database is running and the connection string is correct.",
                e
            )
        }).unwrap(),
        discord_bot: state::DiscordBotConfig::from_env()
    };

    let app = api::routes()
        .merge(pages::routes())
        .with_state(app_sate)
        .layer(TraceLayer::new_for_http());

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();

    println!("Listening on http://localhost:3000");

    axum::serve(listener, app).await.unwrap();
}
