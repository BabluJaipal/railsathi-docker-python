@echo off
REM Rail Sathi Docker Management Script for Windows

setlocal enabledelayedexpansion

REM Function to check if Docker is installed
:check_docker
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not installed or not in PATH
    exit /b 1
)

where docker-compose >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker Compose is not installed or not in PATH
    exit /b 1
)

echo [INFO] Docker and Docker Compose are available
goto :eof

REM Function to setup environment
:setup_env
if not exist .env (
    echo [WARNING] .env file not found, copying from .env.example
    copy .env.example .env
    echo [WARNING] Please edit .env file with your configuration
) else (
    echo [INFO] .env file exists
)
goto :eof

REM Function to build and start services
:start_services
echo [INFO] Building and starting services...
docker-compose up --build -d

echo [INFO] Waiting for services to be ready...
timeout /t 10 /nobreak >nul

REM Check if services are running
docker-compose ps | findstr "Up" >nul
if %errorlevel% equ 0 (
    echo [INFO] Services are running!
    echo [INFO] Application: http://localhost:8000/rs_microservice/
    echo [INFO] API Docs: http://localhost:8000/rs_microservice/docs
    echo [INFO] Health Check: http://localhost:8000/health
) else (
    echo [ERROR] Some services failed to start
    docker-compose logs
)
goto :eof

REM Function to stop services
:stop_services
echo [INFO] Stopping services...
docker-compose down
goto :eof

REM Function to view logs
:view_logs
if "%~2"=="" (
    docker-compose logs -f
) else (
    docker-compose logs -f %2
)
goto :eof

REM Function to restart services
:restart_services
echo [INFO] Restarting services...
docker-compose down
docker-compose up --build -d
goto :eof

REM Function to clean up
:cleanup
echo [INFO] Cleaning up Docker resources...
docker-compose down -v
docker system prune -f
goto :eof

REM Function to access database
:access_db
echo [INFO] Accessing PostgreSQL database...
docker-compose exec db psql -U postgres -d rail_sathi_db
goto :eof

REM Function to run database backup
:backup_db
echo [INFO] Creating database backup...
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~0,4%%dt:~4,2%%dt:~6,2%_%dt:~8,2%%dt:~10,2%%dt:~12,2%"
docker-compose exec db pg_dump -U postgres rail_sathi_db > backup_%timestamp%.sql
echo [INFO] Backup created: backup_%timestamp%.sql
goto :eof

REM Function to show help
:show_help
echo Rail Sathi Docker Management Script
echo.
echo Usage: %0 [COMMAND]
echo.
echo Commands:
echo   start     - Build and start all services
echo   stop      - Stop all services
echo   restart   - Restart all services
echo   logs      - View logs (optional: specify service name)
echo   db        - Access PostgreSQL database
echo   backup    - Create database backup
echo   cleanup   - Clean up Docker resources
echo   status    - Show service status
echo   help      - Show this help message
echo.
echo Examples:
echo   %0 start
echo   %0 logs web
echo   %0 logs db
goto :eof

REM Function to show status
:show_status
echo [INFO] Service Status:
docker-compose ps
goto :eof

REM Main script logic
if "%1"=="start" (
    call :check_docker
    if !errorlevel! neq 0 exit /b 1
    call :setup_env
    call :start_services
) else if "%1"=="stop" (
    call :check_docker
    if !errorlevel! neq 0 exit /b 1
    call :stop_services
) else if "%1"=="restart" (
    call :check_docker
    if !errorlevel! neq 0 exit /b 1
    call :restart_services
) else if "%1"=="logs" (
    call :check_docker
    if !errorlevel! neq 0 exit /b 1
    call :view_logs %1 %2
) else if "%1"=="db" (
    call :check_docker
    if !errorlevel! neq 0 exit /b 1
    call :access_db
) else if "%1"=="backup" (
    call :check_docker
    if !errorlevel! neq 0 exit /b 1
    call :backup_db
) else if "%1"=="cleanup" (
    call :check_docker
    if !errorlevel! neq 0 exit /b 1
    call :cleanup
) else if "%1"=="status" (
    call :check_docker
    if !errorlevel! neq 0 exit /b 1
    call :show_status
) else if "%1"=="help" (
    call :show_help
) else if "%1"=="--help" (
    call :show_help
) else if "%1"=="-h" (
    call :show_help
) else (
    echo [ERROR] Unknown command: %1
    call :show_help
    exit /b 1
)
