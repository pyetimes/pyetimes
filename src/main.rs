mod api;
mod db;
mod models;
mod repo;
mod state;

#[tokio::main(flavor = "current_thread")]
async fn main() {
    println!("Starting PyE TIMES server...");
    println!("Listening on http://localhost:3000");

    dotenv::dotenv().ok();

    let app_sate = state::AppState {
        db: db::create_pool().await.unwrap(),
    };

    let app = api::routes().with_state(app_sate);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
