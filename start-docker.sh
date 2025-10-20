#!/bin/bash
set -e

echo "🚀 Starting PyE Times with Docker Compose..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from .env.example..."
    cp .env.example .env
    echo "⚠️  Please edit .env file with your configuration before continuing."
    echo "   Press Ctrl+C to cancel or Enter to continue with default values..."
    read
fi

# Build and start services
echo "🏗️  Building Docker images..."
docker-compose build

echo "🐳 Starting containers..."
docker-compose up -d postgres

echo "⏳ Waiting for PostgreSQL to be ready..."
sleep 5

# Run migrations
echo "📊 Running database migrations..."
docker-compose run --rm app sh -c "sqlx migrate run || echo '⚠️  Migrations may need to be run manually'"

echo "🎉 Starting application..."
docker-compose up -d app

echo ""
echo "✅ PyE Times is now running!"
echo "🌐 Application: http://localhost:3000"
echo "🗄️  PostgreSQL: localhost:5432"
echo ""
echo "📋 Useful commands:"
echo "   docker-compose logs -f app      # View app logs"
echo "   docker-compose logs -f postgres # View database logs"
echo "   docker-compose down             # Stop all services"
echo "   docker-compose down -v          # Stop and remove volumes"
echo ""
