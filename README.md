# PIER - PHP Infrastructure Environment Ready

[![Docker Pulls](https://img.shields.io/docker/pulls/erkineren/pier.svg)](https://hub.docker.com/r/erkineren/pier)
[![Docker Image Size](https://img.shields.io/docker/image-size/erkineren/pier/8.4)](https://hub.docker.com/r/erkineren/pier)
[![Docker Stars](https://img.shields.io/docker/stars/erkineren/pier.svg)](https://hub.docker.com/r/erkineren/pier)

This project uses Docker for containerization and infrastructure management. The setup includes a PHP-based web server environment with various optimizations and configurations.

## Container Architecture

The infrastructure is built using a single container that combines multiple services:

### Base Image

- PHP 8.x with Apache (8.1, 8.2, 8.3, 8.4)
- Nginx as a reverse proxy
- Composer 2 for PHP dependency management

### Installed Components

- **Web Servers**:
  - Apache (port 8080)
  - Nginx (port 80)
- **PHP Extensions**:
  - GD (with FreeType and JPEG support)
  - Database: PDO, MySQL, MySQLi
  - XML: DOM, SimpleXML
  - Additional: ZIP, Intl, OPCache, MBString, Exif, BCMath, Calendar, FileInfo, Gettext, SOAP, Sockets
  - Redis
  - APCu

### User and Permission Configuration

The container can be run with custom user and group IDs to match your host system's user:

```bash
docker run -e APP_USER_ID=1000 -e APP_GROUP_ID=1000 -e APP_USER=appuser your-image-name
```

- `APP_USER_ID`: User ID (default: 1000)
- `APP_GROUP_ID`: Group ID (default: 1000)
- `APP_USER`: Username (default: appuser)

Both Apache and Nginx are configured to:

1. Start as root (required for port binding)
2. Drop privileges to the specified user after startup
3. Run all processes with the specified user permissions

### Logging Configuration

- Apache logs redirected to stdout/stderr
- Nginx logs redirected to stdout/stderr
- PHP error logs configured
- Logrotate setup for log management

### Security and Performance

- Apache modules enabled: rewrite, headers, expires, env, proxy, proxy_http, remoteip
- PHP configuration optimized with recommended settings
- APCu caching enabled
- Nginx configured as reverse proxy

## Running the Infrastructure

To start the infrastructure:

```bash
docker-compose up -d
```

The container will be available on port 80, with Nginx acting as a reverse proxy to Apache running on port 8080.

## Health Check

A basic health check endpoint is available at the root URL (`/`), which will display a simple HTML page indicating that the server is running.

## Logging

All logs are configured to be accessible through Docker's logging system:

- Apache access logs: stdout
- Apache error logs: stderr
- Nginx access logs: stdout
- Nginx error logs: stderr
- PHP error logs: stderr

## Configuration Files

The container includes several configuration files:

- `nginx.conf`: Nginx reverse proxy configuration
- `php-recommended.ini`: Optimized PHP settings
- `apcu.ini`: APCu caching configuration
- `000-default.conf`: Apache virtual host configuration
- `logrotate.conf`: Log rotation settings

## Maintenance

The container is configured to restart automatically in case of failures (`restart: always` in docker-compose.yml).

## Volume Mounting

The application code is mounted from the host machine to `/var/www/html` in the container, allowing for easy development and updates without rebuilding the container.
