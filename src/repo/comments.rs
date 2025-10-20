use chrono::{Duration, Utc};
use sqlx::PgPool;

use crate::models::{Comment, CommentCreate, CaptchaToken};

pub struct CommentsRepo;

impl CommentsRepo {
    /// Creates a new comment (unapproved by default)
    pub async fn create(
        db: &PgPool,
        comment: &CommentCreate,
    ) -> Result<Comment, sqlx::Error> {
        let query = r"
            INSERT INTO comments (article_id, author_name, content, captcha_token)
            VALUES ($1, $2, $3, $4)
            RETURNING *
        ";

        let comment = sqlx::query_as::<_, Comment>(query)
            .bind(comment.article_id)
            .bind(&comment.author_name)
            .bind(&comment.content)
            .bind(&comment.captcha_token)
            .fetch_one(db)
            .await?;

        Ok(comment)
    }

    /// Gets all approved comments for an article
    pub async fn get_by_article_id(db: &PgPool, article_id: i32) -> Result<Vec<Comment>, sqlx::Error> {
        let query = "SELECT * FROM comments WHERE article_id = $1 AND approved = TRUE ORDER BY created_at ASC";
        
        let comments = sqlx::query_as::<_, Comment>(query)
            .bind(article_id)
            .fetch_all(db)
            .await?;

        Ok(comments)
    }

    /// Gets all pending comments for moderation
    pub async fn get_pending(db: &PgPool) -> Result<Vec<Comment>, sqlx::Error> {
        let query = "SELECT * FROM comments WHERE approved = FALSE ORDER BY created_at DESC";
        
        let comments = sqlx::query_as::<_, Comment>(query)
            .fetch_all(db)
            .await?;

        Ok(comments)
    }

    /// Approves a comment
    pub async fn approve(db: &PgPool, comment_id: i32) -> Result<Comment, sqlx::Error> {
        let query = r"
            UPDATE comments
            SET approved = TRUE, approved_at = NOW()
            WHERE id = $1
            RETURNING *
        ";

        let comment = sqlx::query_as::<_, Comment>(query)
            .bind(comment_id)
            .fetch_one(db)
            .await?;

        Ok(comment)
    }

    /// Deletes a comment
    pub async fn delete(db: &PgPool, comment_id: i32) -> Result<(), sqlx::Error> {
        let query = "DELETE FROM comments WHERE id = $1";
        
        sqlx::query(query)
            .bind(comment_id)
            .execute(db)
            .await?;

        Ok(())
    }
}

pub struct CaptchaRepo;

impl CaptchaRepo {
    /// Creates a new captcha token
    pub async fn create(
        db: &PgPool,
        token: &str,
        solution: &str,
        expires_in_minutes: i64,
    ) -> Result<CaptchaToken, sqlx::Error> {
        let expires_at = Utc::now().naive_utc() + Duration::minutes(expires_in_minutes);
        
        let query = r"
            INSERT INTO captcha_tokens (token, solution, expires_at)
            VALUES ($1, $2, $3)
            RETURNING *
        ";

        let captcha = sqlx::query_as::<_, CaptchaToken>(query)
            .bind(token)
            .bind(solution)
            .bind(expires_at)
            .fetch_one(db)
            .await?;

        Ok(captcha)
    }

    /// Validates a captcha token and solution
    pub async fn validate(
        db: &PgPool,
        token: &str,
        solution: &str,
    ) -> Result<bool, sqlx::Error> {
        let query = r"
            SELECT * FROM captcha_tokens 
            WHERE token = $1 AND used = FALSE AND expires_at > NOW()
        ";

        let captcha: Option<CaptchaToken> = sqlx::query_as::<_, CaptchaToken>(query)
            .bind(token)
            .fetch_optional(db)
            .await?;

        match captcha {
            Some(captcha) if captcha.solution.to_lowercase() == solution.to_lowercase() => {
                Self::mark_as_used(db, token).await?;
                Ok(true)
            }
            _ => Ok(false),
        }
    }

    /// Marks a captcha token as used
    async fn mark_as_used(db: &PgPool, token: &str) -> Result<(), sqlx::Error> {
        let query = "UPDATE captcha_tokens SET used = TRUE WHERE token = $1";
        
        sqlx::query(query)
            .bind(token)
            .execute(db)
            .await?;

        Ok(())
    }

    /// Cleans up expired captcha tokens
    #[allow(dead_code)]
    pub async fn cleanup_expired(db: &PgPool) -> Result<u64, sqlx::Error> {
        let query = "DELETE FROM captcha_tokens WHERE expires_at < NOW()";
        
        let result = sqlx::query(query)
            .execute(db)
            .await?;

        Ok(result.rows_affected())
    }
}
