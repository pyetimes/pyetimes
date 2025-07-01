use sqlx::PgPool;

use crate::models::{Article, ArticleCreate};

pub struct ArticlesRepo;

impl ArticlesRepo {
    pub async fn create(
        db: &PgPool,
        author_id: i32,
        article: &ArticleCreate,
    ) -> Result<Article, sqlx::Error> {
        let query = r#"
            INSERT INTO articles (title, slug, content, author_id, tags, excerpt)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING *
        "#;

        let article = sqlx::query_as::<_, Article>(query)
            .bind(&article.title)
            .bind(&article.slug)
            .bind(&article.content)
            .bind(author_id)
            .bind(&article.tags)
            .bind(&article.excerpt)
            .fetch_one(db)
            .await?;

        Ok(article)
    }

    pub async fn get_all(db: &PgPool) -> Result<Vec<Article>, sqlx::Error> {
        let query = "SELECT * FROM articles ORDER BY created_at DESC";
        let articles = sqlx::query_as::<_, Article>(query).fetch_all(db).await?;

        Ok(articles)
    }

    pub async fn get_by_slug(db: &PgPool, title: &str) -> Result<Article, sqlx::Error> {
        let query = "SELECT * FROM articles WHERE slug = $1";
        let article = sqlx::query_as::<_, Article>(query)
            .bind(title)
            .fetch_one(db)
            .await?;

        Ok(article)
    }
}
