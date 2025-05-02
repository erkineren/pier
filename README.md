# PIER - PHP Infrastructure Environment Ready

This project uses Docker for containerization and infrastructure management. The setup includes a PHP-based web server environment with various optimizations and configurations.

## Container Architecture

The infrastructure is built using a single container that combines multiple services:

### Base Image

- PHP 8.1 with Apache
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
