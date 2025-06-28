pub async fn create_pool() -> Result<sqlx::PgPool, sqlx::Error> {
    let database_url =
        std::env::var("DATABASE_URL").unwrap_or_else(|_| panic!("DATABASE_URL must be set"));

    let pool = sqlx::PgPool::connect(&database_url).await?;

    Ok(pool)
}
