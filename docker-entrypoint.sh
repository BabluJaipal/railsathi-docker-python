#!/bin/bash
set -e

# Function to wait for PostgreSQL
wait_for_postgres() {
    echo "Waiting for PostgreSQL to be ready..."
    while ! pg_isready -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER"; do
        echo "PostgreSQL is unavailable - sleeping"
        sleep 1
    done
    echo "PostgreSQL is ready!"
}

# Function to test database connection
test_db_connection() {
    echo "Testing database connection..."
    python -c "
import sys
sys.path.append('/app')
from database import test_connection
if test_connection():
    print('Database connection successful!')
    sys.exit(0)
else:
    print('Database connection failed!')
    sys.exit(1)
"
}

# Function to run database initialization/migrations
run_migrations() {
    echo "Running database initialization..."
    python -c "
import sys
sys.path.append('/app')
from database import init_database
if init_database():
    print('Database initialization successful!')
else:
    print('Database initialization failed!')
    sys.exit(1)
"
}

# Main execution
echo "Starting FastAPI Rail Sathi application..."

# Wait for PostgreSQL to be ready
wait_for_postgres

# Test database connection
test_db_connection

# Run database initialization
run_migrations

echo "Database setup complete. Starting application..."

# Execute the main command
exec "$@"
