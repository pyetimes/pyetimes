use tracing::info;

use crate::{
    models::{Article, ArticleDiscordUpdate},
    state::DiscordBotConfig,
};

pub async fn notify_discord_bot(discord_bot: DiscordBotConfig, article: Article) {
    let article_update = ArticleDiscordUpdate {
        title: &article.title,
        url: &format!("https://pyetimes.com/articles/{}", article.slug),
        description: &article.excerpt,
        published: article.published,
    };

    let client = reqwest::Client::new();

    let response = client
        .post(format!("{}/article", discord_bot.url))
        .body(serde_json::to_string(&article_update).unwrap())
        .header("Content-Type", "application/json")
        .header("x-webhook-token", &discord_bot.token)
        .send()
        .await;

    info!(
        "Notifying Discord bot at {} with article: {}",
        format!("{}/article", discord_bot.url),
        article.slug
    );

    match response {
        Ok(resp) if resp.status().is_success() => (),
        Ok(resp) => info!("Discord bot responded with status: {}", resp.status()),
        Err(err) => info!("Failed to notify Discord bot: {}", err),
    }
}
