use bcrypt::hash;
use sqlx::PgPool;

use crate::models::{Article, ArticleCreate, Author, AuthorCreate};

pub struct ArticlesRepo;

impl ArticlesRepo {
    pub async fn create(
        db: &PgPool,
        author_id: i32,
        article: &ArticleCreate,
    ) -> Result<Article, sqlx::Error> {
        let query = r#"
            INSERT INTO articles (title, slug, content, author_id, tags)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING id, title, slug, content, author_id, published, tags, created_at, updated_at
        "#;

        let article = sqlx::query_as::<_, Article>(query)
            .bind(&article.title)
            .bind(&article.slug)
            .bind(&article.content)
            .bind(author_id)
            .bind(&article.tags)
            .fetch_one(db)
            .await?;

        Ok(article)
    }

    pub async fn get_all(db: &PgPool) -> Result<Vec<Article>, sqlx::Error> {
        let query = "SELECT * FROM articles";
        let articles = sqlx::query_as::<_, Article>(query).fetch_all(db).await?;

        Ok(articles)
    }

    pub async fn get_by_id(db: &PgPool, id: i32) -> Result<Option<Article>, sqlx::Error> {
        let query = "SELECT * FROM articles WHERE id = $1";
        let article = sqlx::query_as::<_, Article>(query)
            .bind(id)
            .fetch_optional(db)
            .await?;

        Ok(article)
    }
}
