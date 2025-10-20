# PyE Times

PyE Times is a news website built for the PyE community, developed in Rust using the Axum web framework and PostgreSQL database.

## 🆕 Latest Features (January 2025)

### Authentication & User Management 🔐
- **User Registration**: Complete signup flow with password strength indicator
- **Login System**: Secure authentication with session management
- **User Profiles**: Personal dashboard with biography, articles, and settings
- **Protected Editor**: Article creation requires authentication
- **Session Management**: Automatic login/logout with localStorage

### Previous Features (October 2025)
- **Comments System**: Anonymous commenting with captcha protection and moderation workflow
- **Search Functionality**: Full-text search across articles by title, content, tags, and sections
- **Games Section**: New dedicated section for gaming-related articles
- **Improved Code Quality**: Cleaned up codebase with better documentation and error handling

See [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) for the latest authentication system details, [IMPROVEMENTS.md](IMPROVEMENTS.md) for previous changes, and [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for API documentation.

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

# CORS Configuration (production)
CORS_ALLOWED_ORIGIN=https://pyetimes.com
```

the discord bot repository is [PyETimes DsBot](https://github.com/C-Ewan/dsbot-pyetimes)

### Environment Variables Description

- `DATABASE_URL`: PostgreSQL connection string (required)
- `DISCORD_BOT_URL`: Discord webhook URL for bot integration (optional)
- `DISCORD_BOT_TOKEN`: Discord bot token for authentication (optional)
- `CORS_ALLOWED_ORIGIN`: Allowed origin for CORS in production mode (optional, defaults to https://pyetimes.com)
- `DOMAIN`: Domain used for article URLs in Discord notifications (optional, defaults to https://pyetimes.com)

## Building and Running

### Local Development

1. **Clone the repository:**
   ```bash
   git clone https://github.com/darilrt/pyetimes
   cd pyetimes
   ```

2. **Install system dependencies:**
   
   Ubuntu/Debian:
   ```bash
   sudo apt-get install pkg-config libssl-dev
   ```
   
   Fedora/RHEL:
   ```bash
   sudo yum install pkg-config openssl-devel
   ```
   
   Arch Linux:
   ```bash
   sudo pacman -S pkg-config openssl
   ```

3. **Set up the database:**
   ```bash
   # Create a PostgreSQL database
   createdb pyetimes_db
   
   # Or using psql
   psql -c "CREATE DATABASE pyetimes_db;"
   ```

4. **Configure environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials and Discord settings
   ```

5. **Run database migrations:**
   ```bash
   sqlx migrate run
   ```

6. **Install dependencies and build:**
   ```bash
   cargo build
   ```

7. **Run the application:**
   ```bash
   cargo run
   ```

The server will start on `http://localhost:3000`

### Quick Start for Users

1. **Register an account**:
   - Visit `http://localhost:3000/register`
   - Fill in your details (name, email, password)
   - Auto-login after successful registration

2. **Create your first article**:
   - Navigate to `http://localhost:3000/editor`
   - Write your article in Markdown
   - Save and preview your draft

3. **Manage your profile**:
   - Access your profile at `http://localhost:3000/profile`
   - Update your biography
   - View your articles
   - Change your password

For detailed user instructions, see [USER_GUIDE.md](USER_GUIDE.md).

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

### Using Docker Compose (Recommended)

The easiest way to run PyE Times with all dependencies:

1. **Configure environment (optional):**
   ```bash
   cp .env.example .env
   # Edit .env with your settings (or use defaults)
   ```

2. **Start everything with one command:**
   ```bash
   ./start-docker.sh
   ```

   Or manually:
   ```bash
   docker-compose up -d
   ```

3. **View logs:**
   ```bash
   docker-compose logs -f app
   ```

4. **Stop services:**
   ```bash
   docker-compose down
   ```

5. **Reset everything (including database):**
   ```bash
   docker-compose down -v
   ```

#### What's included:
- ✅ PostgreSQL 17 database (automatically configured)
- ✅ Database migrations (run automatically)
- ✅ PyE Times application
- ✅ Health checks
- ✅ Persistent data storage

#### Environment Variables for Docker:
```env
# Required (provided by docker-compose)
DATABASE_URL=postgres://pyetimes:pyetimes_password@postgres:5432/pyetimes_db

# Optional
DISCORD_BOT_URL=your_discord_webhook_url
DISCORD_BOT_TOKEN=your_discord_bot_token
CORS_ALLOWED_ORIGIN=https://pyetimes.com
DOMAIN=https://pyetimes.com
RUST_LOG=info
```

### Using Docker (Manual)

#### Manual Docker Build

1. **Build the Docker image:**
   ```bash
   docker build -t pyetimes .
   ```

2. **Run with external database:**
   ```bash
   docker run -p 3000:3000 \
     -e DATABASE_URL=postgres://user:password@host:5432/pyetimes_db \
     -e DOMAIN=https://yourdomain.com \
     pyetimes
   ```

## Development

### Project Structure

```
src/
├── api/           # API endpoints and routes
│   ├── articles.rs  # Article management
│   ├── authors.rs   # Author management
│   ├── comments.rs  # 🆕 Comment system with captcha
│   ├── search.rs    # 🆕 Search functionality
│   └── mod.rs
├── middleware/    # Custom middleware (caching, etc.)
├── models/        # Data models and structures
│   ├── article.rs
│   ├── author.rs
│   ├── comment.rs   # 🆕 Comment models
│   ├── section.rs
│   └── mod.rs
├── pages/         # Web page handlers
│   ├── mod.rs
│   └── ...
├── repo/          # Database repository layer
│   ├── articles.rs
│   ├── authors.rs
│   ├── comments.rs  # 🆕 Comment repository
│   ├── search.rs    # 🆕 Search repository
│   ├── sections.rs
│   └── mod.rs
├── utils/         # Utility functions
│   ├── auth.rs
│   ├── captcha.rs   # 🆕 Captcha generation and validation
│   ├── discord.rs
│   ├── markdown.rs
│   └── mod.rs
├── web/           # Web components and templates
│   ├── components/
│   │   ├── header.rs
│   │   ├── meta.rs
│   │   └── mod.rs
│   └── pages/
│       ├── editor.rs
│       └── mod.rs
├── db.rs          # Database connection and setup
├── error.rs       # Error handling
├── main.rs        # Application entry point
└── state.rs       # Application state management

migrations/        # Database migrations
├── 20250915032353_initial_setup.up.sql
├── 20250920000000_add_comments_system.up.sql  # 🆕 Comments tables
└── 20250921000000_add_games_section.up.sql    # 🆕 Games section

web/
├── components/    # Reusable UI components (.mk files)
│   ├── header.mk      # 🔄 Updated with auth links
│   ├── footer.mk
│   └── meta.mk
├── pages/         # Page templates (.mk files)
│   ├── index.mk
│   ├── article.mk
│   ├── editor.mk      # 🔄 Protected with authentication
│   ├── register.mk    # 🔄 Improved with validations
│   ├── login.mk       # 🆕 New login page
│   ├── profile.mk     # 🆕 New user profile page
│   ├── about.mk
│   ├── error.mk
│   └── 404.mk
└── static/        # Static assets (CSS, JS, images)
    ├── css/
    ├── js/
    └── images/
```

### Database Setup

The application uses SQLx for database operations. Make sure your PostgreSQL database is running and accessible with the credentials specified in your `DATABASE_URL`.

To run migrations:
```bash
sqlx migrate run
```

To rollback the last migration:
```bash
sqlx migrate revert
```

### API Documentation

For detailed API documentation and usage examples, see [QUICK_REFERENCE.md](QUICK_REFERENCE.md).

#### Authentication Endpoints

- `GET /register` - User registration page
- `GET /login` - User login page
- `GET /profile` - User profile page (requires authentication)
- `GET /editor` - Article editor (requires authentication)

#### Key API Endpoints

- `GET /api/comments/captcha` - Generate captcha challenge
- `POST /api/comments` - Submit a comment (requires captcha)
- `GET /api/comments/article/:id` - Get approved comments for an article
- `GET /api/search?q=query` - Search articles
- `GET /api/search/section/:id` - Get articles by section
- `GET /api/search/tag/:tag` - Get articles by tag

#### Admin Endpoints

- `GET /api/comments/pending` - List pending comments
- `POST /api/comments/:id/approve` - Approve a comment
- `DELETE /api/comments/:id` - Delete a comment

**Note**: Admin endpoints should be protected with authentication in production.

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
- **rand**: 🆕 Random number generation (for captcha)
- **base64**: 🆕 Base64 encoding (for captcha images)
- **lazy_static**: 🆕 Static initialization (for rate limiting)

### Development Dependencies

See `Cargo.toml` for the complete list of dependencies and their versions.

## License

This project is licensed under the terms specified in `LICENSE.txt`.

## Support

For questions or issues, please open an issue on the repository or contact the PyE community.
