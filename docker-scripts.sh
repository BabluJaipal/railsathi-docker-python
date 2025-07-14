#!/bin/bash

# Rail Sathi Docker Management Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed or not in PATH"
        exit 1
    fi
    
    print_status "Docker and Docker Compose are available"
}

# Function to setup environment
setup_env() {
    if [ ! -f .env ]; then
        print_warning ".env file not found, copying from .env.example"
        cp .env.example .env
        print_warning "Please edit .env file with your configuration"
    else
        print_status ".env file exists"
    fi
}

# Function to build and start services
start_services() {
    print_status "Building and starting services..."
    docker-compose up --build -d
    
    print_status "Waiting for services to be ready..."
    sleep 10
    
    # Check if services are running
    if docker-compose ps | grep -q "Up"; then
        print_status "Services are running!"
        print_status "Application: http://localhost:8000/rs_microservice/"
        print_status "API Docs: http://localhost:8000/rs_microservice/docs"
        print_status "Health Check: http://localhost:8000/health"
    else
        print_error "Some services failed to start"
        docker-compose logs
    fi
}

# Function to stop services
stop_services() {
    print_status "Stopping services..."
    docker-compose down
}

# Function to view logs
view_logs() {
    if [ -z "$1" ]; then
        docker-compose logs -f
    else
        docker-compose logs -f "$1"
    fi
}

# Function to restart services
restart_services() {
    print_status "Restarting services..."
    docker-compose down
    docker-compose up --build -d
}

# Function to clean up
cleanup() {
    print_status "Cleaning up Docker resources..."
    docker-compose down -v
    docker system prune -f
}

# Function to access database
access_db() {
    print_status "Accessing PostgreSQL database..."
    docker-compose exec db psql -U postgres -d rail_sathi_db
}

# Function to run database backup
backup_db() {
    print_status "Creating database backup..."
    timestamp=$(date +%Y%m%d_%H%M%S)
    docker-compose exec db pg_dump -U postgres rail_sathi_db > "backup_${timestamp}.sql"
    print_status "Backup created: backup_${timestamp}.sql"
}

# Function to show help
show_help() {
    echo "Rail Sathi Docker Management Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start     - Build and start all services"
    echo "  stop      - Stop all services"
    echo "  restart   - Restart all services"
    echo "  logs      - View logs (optional: specify service name)"
    echo "  db        - Access PostgreSQL database"
    echo "  backup    - Create database backup"
    echo "  cleanup   - Clean up Docker resources"
    echo "  status    - Show service status"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs web"
    echo "  $0 logs db"
}

# Function to show status
show_status() {
    print_status "Service Status:"
    docker-compose ps
}

# Main script logic
case "$1" in
    start)
        check_docker
        setup_env
        start_services
        ;;
    stop)
        check_docker
        stop_services
        ;;
    restart)
        check_docker
        restart_services
        ;;
    logs)
        check_docker
        view_logs "$2"
        ;;
    db)
        check_docker
        access_db
        ;;
    backup)
        check_docker
        backup_db
        ;;
    cleanup)
        check_docker
        cleanup
        ;;
    status)
        check_docker
        show_status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
