use axum::Router;

mod pye_times {
    use axum::{Router, response::Html, routing::get};
    use tower::ServiceBuilder;
    use tower_http::services::ServeDir;

    pub fn routes() -> Router {
        Router::new().route("/", get(index)).nest_service(
            "/css",
            ServiceBuilder::new().service(ServeDir::new("static/css")),
        )
    }

    async fn index() -> Html<String> {
        // Load a template file in the `templates` directory
        let template = magik::get("./templates/layout.html");

        Html(template.unwrap().to_string())
    }
}

#[tokio::main(flavor = "current_thread")]
async fn main() {
    println!("Starting PyE TIMES server...");
    println!("Listening on http://localhost:3000");

    let app = Router::new().merge(pye_times::routes());

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
