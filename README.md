# PyE Times

PyE Times is a news website built for the PyE community, developed in Rust using the Axum web framework and PostgreSQL database.

## Prerequisites

Before running PyE Times, make sure you have the following installed:

If you want to run this application locally, you will need:
- [Rust](https://rustup.rs/) (at least 1.86.0)
- [PostgreSQL](https://www.postgresql.org/download/) (version 17 or higher)

if you want to run this application in a container, you will need:
- [Docker](https://www.docker.com/get-started) (optional, for containerized deployment)

## Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
# Database Configuration
DATABASE_URL=postgres://username:password@localhost:5432/pyetimes_db

# Discord Bot Configuration (optional)
DISCORD_BOT_URL=discord_bot_url
DISCORD_BOT_TOKEN=your-discord-bot-token
```

the discord bot repository is [PyETimes DsBot](https://github.com/C-Ewan/dsbot-pyetimes)

### Environment Variables Description

- `DATABASE_URL`: PostgreSQL connection string (required)
- `DISCORD_BOT_URL`: Discord webhook URL for bot integration (optional)
- `DISCORD_BOT_TOKEN`: Discord bot token for authentication (optional)

## Building and Running

### Local Development

1. **Clone the repository:**
   ```bash
   git clone https://github.com/darilrt/pyetimes
   cd pyetimes
   ```

2. **Set up the database:**
   ```bash
   # Create a PostgreSQL database
   createdb pyetimes_db
   
   # Or using psql
   psql -c "CREATE DATABASE pyetimes_db;"
   ```

3. **Configure environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials and Discord settings
   ```

4. **Install dependencies and build:**
   ```bash
   cargo build
   ```

5. **Run the application:**
   ```bash
   cargo run
   ```

The server will start on `http://localhost:3000`

To reload the application during development, you need install `cargo-watch` and use:
```bash
cargo watch -x run
```

### Production Build

1. **Build optimized release:**
   ```bash
   cargo build --release
   ```

2. **Run the production binary:**
   ```bash
   ./target/release/pyetimes
   ```

### Using Docker

#### Manual Docker Build

1. **Build the Docker image:**
   ```bash
   docker build -t pyetimes .
   ```

2. **Run with external database:**
   ```bash
   docker run -p 3000:3000 \
     -e DATABASE_URL=postgres://user:password@host:5432/pyetimes_db \
     pyetimes
   ```

## Development

### Project Structure

```
src/
├── api/           # API endpoints and routes
├── middleware/    # Custom middleware (caching, etc.)
├── models/        # Data models and structures
├── pages/         # Web page handlers
├── repo/          # Database repository layer
├── utils/         # Utility functions (auth, markdown, discord)
├── web/           # Web components and templates
├── db.rs          # Database connection and setup
├── error.rs       # Error handling
├── main.rs        # Application entry point
└── state.rs       # Application state management

web/
├── components/    # Reusable UI components (.mk files)
├── pages/         # Page templates (.mk files)
└── static/        # Static assets (CSS, JS, images)
```

### Database Setup

The application uses SQLx for database operations. Make sure your PostgreSQL database is running and accessible with the credentials specified in your `DATABASE_URL`.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Dependencies

### Main Dependencies

- **axum**: Modern web framework for Rust
- **tokio**: Asynchronous runtime
- **sqlx**: Async SQL toolkit with PostgreSQL support
- **serde**: Serialization/deserialization framework
- **tower**: Modular service library
- **magik**: Custom framework components [Magik Repository](github.com/darilrt/magik)
- **chrono**: Date and time library
- **bcrypt**: Password hashing
- **pulldown-cmark**: Markdown parser

### Development Dependencies

See `Cargo.toml` for the complete list of dependencies and their versions.

## License

This project is licensed under the terms specified in `LICENSE.txt`.

## Support

For questions or issues, please open an issue on the repository or contact the PyE community.
