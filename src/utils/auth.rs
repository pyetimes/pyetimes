use crate::models::{Author, ErrorPayload};
use crate::repo::AuthorsRepo;
use axum::http::StatusCode;
use sqlx::PgPool;

/// Validates user credentials and returns the authenticated author if successful
///
/// # Arguments
/// * `db` - Database connection pool
/// * `email` - User's email address
/// * `password` - Plain text password to verify
///
/// # Returns
/// * `Ok(Some(Author))` - Authentication successful
/// * `Ok(None)` - User not found
/// * `Err(ErrorPayload)` - Database error or invalid credentials
pub async fn validate_user(
    db: &PgPool,
    email: &str,
    password: &str,
) -> Result<Option<Author>, ErrorPayload> {
    let author = AuthorsRepo::get_by_email(db, email).await;

    if let Err(err) = author {
        return Err(ErrorPayload::new(
            StatusCode::INTERNAL_SERVER_ERROR,
            format!("Error validating author credentials: {}", err),
        ));
    }

    let author = author.unwrap();

    if let Some(author) = author {
        let password_valid = bcrypt::verify(password, &author.password_hash).unwrap_or(false);

        if password_valid {
            Ok(Some(author))
        } else {
            Ok(None) // Invalid password
        }
    } else {
        Ok(None) // User not found
    }
}

/// Convenience function that returns an error for unauthorized access
/// Use this when you need to return an error instead of Option
pub async fn validate_user_required(
    db: &PgPool,
    email: &str,
    password: &str,
) -> Result<Author, ErrorPayload> {
    match validate_user(db, email, password).await? {
        Some(author) => Ok(author),
        None => Err(ErrorPayload::new(
            StatusCode::UNAUTHORIZED,
            "Invalid author credentials".to_string(),
        )),
    }
}
