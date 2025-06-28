use sqlx::PgPool;

use crate::models::Author;

pub struct AuthorsRepo;

impl AuthorsRepo {
    pub async fn get_all(db: &PgPool) -> Result<Vec<Author>, sqlx::Error> {
        let query = "SELECT id, name, email, bio, profile_image, created_at FROM authors";
        let author = sqlx::query_as::<_, Author>(query).fetch_all(db).await?;

        Ok(author)
    }
}
