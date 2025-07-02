use sqlx::PgPool;

use crate::models::{Article, Author, Section};

pub struct FeedRepo;

impl FeedRepo {
    pub async fn get(
        db: &PgPool,
    ) -> Result<(Option<(Article, Author)>, Vec<Section>), sqlx::Error> {
        Ok((
            Self::get_main_story(db).await?,
            Self::get_sections(db).await?,
        ))
    }

    async fn get_main_story(db: &PgPool) -> Result<Option<(Article, Author)>, sqlx::Error> {
        let query = "SELECT * FROM articles WHERE id = (SELECT article_id FROM main_story WHERE disabled = FALSE LIMIT 1)";
        let main_story = sqlx::query_as::<_, Article>(query)
            .fetch_optional(db)
            .await?;

        if let Some(article) = &main_story {
            let author_query = "SELECT * FROM authors WHERE id = $1";
            let author = sqlx::query_as::<_, Author>(author_query)
                .bind(article.author_id)
                .fetch_one(db)
                .await?;

            return Ok(Some((article.clone(), author)));
        }

        Ok(None)
    }

    async fn get_sections(db: &PgPool) -> Result<Vec<Section>, sqlx::Error> {
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
