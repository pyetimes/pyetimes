use sqlx::PgPool;
use crate::models::Article;

pub struct SearchRepo;

impl SearchRepo {
    /// Search articles by title, content, or tags
    pub async fn search_articles(
        db: &PgPool,
        query: &str,
        limit: i64,
        offset: i64,
    ) -> Result<Vec<Article>, sqlx::Error> {
        let search_pattern = format!("%{}%", query.to_lowercase());
        
        let sql = r"
            SELECT * FROM articles 
            WHERE published = TRUE 
            AND (
                LOWER(title) LIKE $1 
                OR LOWER(content) LIKE $1 
                OR LOWER(excerpt) LIKE $1
                OR EXISTS (
                    SELECT 1 FROM unnest(tags) tag 
                    WHERE LOWER(tag) LIKE $1
                )
            )
            ORDER BY 
                CASE 
                    WHEN LOWER(title) LIKE $1 THEN 1
                    WHEN EXISTS (SELECT 1 FROM unnest(tags) tag WHERE LOWER(tag) LIKE $1) THEN 2
                    ELSE 3
                END,
                published_at DESC NULLS LAST,
                created_at DESC
            LIMIT $2 OFFSET $3
        ";
        
        let articles = sqlx::query_as::<_, Article>(sql)
            .bind(&search_pattern)
            .bind(limit)
            .bind(offset)
            .fetch_all(db)
            .await?;
        
        Ok(articles)
    }
    
    /// Count search results
    pub async fn count_search_results(
        db: &PgPool,
        query: &str,
    ) -> Result<i64, sqlx::Error> {
        let search_pattern = format!("%{}%", query.to_lowercase());
        
        let sql = r"
            SELECT COUNT(*) FROM articles 
            WHERE published = TRUE 
            AND (
                LOWER(title) LIKE $1 
                OR LOWER(content) LIKE $1 
                OR LOWER(excerpt) LIKE $1
                OR EXISTS (
                    SELECT 1 FROM unnest(tags) tag 
                    WHERE LOWER(tag) LIKE $1
                )
            )
        ";
        
        let (count,): (i64,) = sqlx::query_as(sql)
            .bind(&search_pattern)
            .fetch_one(db)
            .await?;
        
        Ok(count)
    }
    
    /// Search articles by section
    pub async fn get_articles_by_section(
        db: &PgPool,
        section_id: i32,
        limit: i64,
        offset: i64,
    ) -> Result<Vec<Article>, sqlx::Error> {
        let sql = r"
            SELECT * FROM articles 
            WHERE published = TRUE AND section_id = $1
            ORDER BY published_at DESC NULLS LAST, created_at DESC
            LIMIT $2 OFFSET $3
        ";
        
        let articles = sqlx::query_as::<_, Article>(sql)
            .bind(section_id)
            .bind(limit)
            .bind(offset)
            .fetch_all(db)
            .await?;
        
        Ok(articles)
    }
    
    /// Search articles by tag
    pub async fn get_articles_by_tag(
        db: &PgPool,
        tag: &str,
        limit: i64,
        offset: i64,
    ) -> Result<Vec<Article>, sqlx::Error> {
        let tag_lower = tag.to_lowercase();
        
        let sql = r"
            SELECT * FROM articles 
            WHERE published = TRUE 
            AND EXISTS (
                SELECT 1 FROM unnest(tags) article_tag 
                WHERE LOWER(article_tag) = $1
            )
            ORDER BY published_at DESC NULLS LAST, created_at DESC
            LIMIT $2 OFFSET $3
        ";
        
        let articles = sqlx::query_as::<_, Article>(sql)
            .bind(&tag_lower)
            .bind(limit)
            .bind(offset)
            .fetch_all(db)
            .await?;
        
        Ok(articles)
    }
}
