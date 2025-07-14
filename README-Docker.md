# Rail Sathi FastAPI Application - Docker Setup

This document provides instructions for running the Rail Sathi FastAPI application using Docker and Docker Compose.

## Prerequisites

- Docker
- Docker Compose
- Git (to clone the repository)

## Quick Start

1. **Clone the repository** (if not already done):
   ```bash
   git clone <repository-url>
   cd bablu_fluter
   ```

2. **Configure environment variables**:
   ```bash
   cp .env.example .env
   ```
   Edit the `.env` file and update the values as needed:
   - `POSTGRES_PASSWORD`: Set a secure password for PostgreSQL
   - Update email configuration if needed
   - Update Google Cloud Storage configuration if needed

3. **Build and start the application**:
   ```bash
   docker-compose up --build
   ```

4. **Access the application**:
   - API: http://localhost:8000/rs_microservice/
   - API Documentation: http://localhost:8000/rs_microservice/docs
   - Health Check: http://localhost:8000/health

## Services

### PostgreSQL Database
- **Container**: `rail_sathi_db`
- **Port**: 5432 (exposed on host)
- **Database**: `rail_sathi_db`
- **User**: `postgres` (configurable via .env)
- **Data**: Persisted in Docker volume `postgres_data`

### FastAPI Application
- **Container**: `rail_sathi_app`
- **Port**: 5002 (mapped to 8000 on host)
- **Health Check**: Available at `/health`
- **API Docs**: Available at `/rs_microservice/docs`

## Environment Variables

Key environment variables in `.env`:

```env
# Database Configuration
POSTGRES_DB=rail_sathi_db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password_here
POSTGRES_HOST=db
POSTGRES_PORT=5432

# Application Configuration
APP_HOST=0.0.0.0
APP_PORT=5002
DEBUG=False

# Email Configuration (optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASSWORD=your_app_password

# Google Cloud Storage (optional)
GOOGLE_CLOUD_PROJECT=your_project_id
GOOGLE_CLOUD_BUCKET=your_bucket_name
```

## Database Schema

The database is automatically initialized with the following tables:
- `trains_traindetails`: Train information
- `station_zone`: Railway zones
- `station_division`: Railway divisions
- `station_Depot`: Railway depots
- `rail_sathi_railsathicomplain`: Main complaints table
- `rail_sathi_railsathicomplainmedia`: Media files for complaints

Sample data is also inserted for testing purposes.

## API Endpoints

Main API endpoints available:

- `GET /rs_microservice/` - Root endpoint
- `GET /rs_microservice/complaint/get/{complain_id}` - Get complaint by ID
- `GET /rs_microservice/complaint/get/date/{date_str}` - Get complaints by date
- `POST /rs_microservice/complaint/add` - Create new complaint
- `PATCH /rs_microservice/complaint/update/{complain_id}` - Update complaint
- `PUT /rs_microservice/complaint/update/{complain_id}` - Replace complaint
- `DELETE /rs_microservice/complaint/delete/{complain_id}` - Delete complaint
- `DELETE /rs_microservice/media/delete/{complain_id}` - Delete complaint media
- `GET /rs_microservice/train_details/{train_no}` - Get train details
- `GET /health` - Health check

## Docker Commands

### Start services
```bash
docker-compose up -d
```

### Stop services
```bash
docker-compose down
```

### View logs
```bash
docker-compose logs -f web
docker-compose logs -f db
```

### Rebuild and restart
```bash
docker-compose down
docker-compose up --build
```

### Access database directly
```bash
docker-compose exec db psql -U postgres -d rail_sathi_db
```

### Access application container
```bash
docker-compose exec web bash
```

## Volumes

- `postgres_data`: PostgreSQL data persistence
- `./uploads`: Application uploads directory
- `./logs`: Application logs directory

## Troubleshooting

### Database Connection Issues
1. Check if PostgreSQL container is running:
   ```bash
   docker-compose ps
   ```

2. Check database logs:
   ```bash
   docker-compose logs db
   ```

3. Verify environment variables in `.env` file

### Application Issues
1. Check application logs:
   ```bash
   docker-compose logs web
   ```

2. Verify the application is healthy:
   ```bash
   curl http://localhost:8000/health
   ```

### Port Conflicts
If port 8000 is already in use, modify the port mapping in `docker-compose.yml`:
```yaml
ports:
  - "8001:5002"  # Change 8000 to 8001 or any available port
```

## Development

For development, you can mount the source code as a volume to enable hot reloading:

```yaml
# Add to web service in docker-compose.yml
volumes:
  - .:/app
  - ./uploads:/app/uploads
  - ./logs:/app/logs
```

## Production Considerations

For production deployment:

1. Use environment-specific `.env` files
2. Set `DEBUG=False`
3. Use a reverse proxy (nginx) in front of the application
4. Set up proper logging and monitoring
5. Use Docker secrets for sensitive information
6. Configure backup for PostgreSQL data
7. Set up SSL/TLS certificates

## Support

For issues and questions, please refer to the application documentation or contact the development team.
