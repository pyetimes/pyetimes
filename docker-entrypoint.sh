#!/bin/sh
set -e

echo "🔄 Waiting for PostgreSQL to be ready..."
until pg_isready -h postgres -U pyetimes > /dev/null 2>&1; do
    echo "⏳ PostgreSQL is unavailable - sleeping"
    sleep 1
done

echo "✅ PostgreSQL is ready!"

# Run database migrations if directory exists
if [ -d "/app/migrations" ]; then
    echo "📊 Running database migrations..."
    if [ -f "/usr/local/bin/sqlx" ]; then
        if /usr/local/bin/sqlx migrate run 2>&1; then
            echo "✅ Migrations completed successfully"
        else
            echo "⚠️  Migrations failed or already applied"
        fi
    else
        echo "⚠️  sqlx-cli not found, skipping migrations"
    fi
fi

echo "🚀 Starting PyE Times..."
exec pyetimes
