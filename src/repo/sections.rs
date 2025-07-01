use sqlx::PgPool;

use crate::models::Section;

pub struct SectionsRepo;

impl SectionsRepo {
    pub async fn get_feed(db: &PgPool) -> Result<Vec<Section>, sqlx::Error> {
        let query = "SELECT * FROM sections ORDER BY priority ASC";

        let mut sections = sqlx::query_as::<_, Section>(query).fetch_all(db).await?;

        let articles_query = r#"
            SELECT * FROM articles 
            WHERE 
                section_id = $1 AND 
                published = TRUE 
            ORDER BY published_at ASC
        "#;

        for section in &mut sections {
            section.articles = sqlx::query_as::<_, crate::models::Article>(articles_query)
                .bind(section.id)
                .fetch_all(db)
                .await?;
        }

        Ok(sections)
    }
}
