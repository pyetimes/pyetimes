use sqlx::PgPool;

use crate::models::User;

pub struct UsersRepo;

impl UsersRepo {
    pub async fn get_user_by_id(db: &PgPool, user_id: i32) -> Result<Option<User>, sqlx::Error> {
        let query = "SELECT * FROM users WHERE id = $1";
        let user = sqlx::query_as::<_, User>(query)
            .bind(user_id)
            .fetch_optional(db)
            .await?;

        Ok(user)
    }
}
