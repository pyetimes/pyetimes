use sqlx::PgPool;

#[derive(Clone)]
pub struct DiscordBotConfig {
    pub url: String,
    pub token: String,
}

#[derive(Clone)]
pub struct AppState {
    pub db: PgPool,
    pub discord_bot: Option<DiscordBotConfig>,
}

impl DiscordBotConfig {
    pub fn from_env() -> Option<Self> {
        let url = std::env::var("DISCORD_BOT_URL").ok()?;
        let token = std::env::var("DISCORD_BOT_TOKEN").ok()?;
        Some(Self { url, token })
    }
}
