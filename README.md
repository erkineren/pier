# PIER - PHP Infrastructure Environment Ready

A comprehensive dockerized infrastructure for PHP applications with a complete stack of services ready for development and production.

## Features

- **PHP 8.1** with Apache
- **MariaDB 10.8** database
- **Redis 6** for caching
- **Elasticsearch 7.17** for search functionality
- **Nginx** as a proxy server
- **SSH Server** for remote access
- Configured with sensible defaults and ready for customization

## Requirements

- Docker
- Docker Compose

## Quick Start

1. Clone this repository:

   ```bash
   git clone https://github.com/erkineren/pier.git
   cd pier
   ```

2. Create a `.env` file (optional, for customizing configurations):

   ```bash
   cp .env.example .env
   ```

3. Start the services:

   ```bash
   docker-compose up -d
   ```

4. Access your application:
   - Web: http://localhost:8005
   - MariaDB: localhost:3307 (default credentials in docker-compose.yml)
   - Elasticsearch: http://localhost:9200
   - SSH: ssh appuser@localhost -p 5555

## Configuration

### Environment Variables

Key environment variables that can be set in `.env`:

- `APP_PUBLIC_PATH`: Path to your PHP application public directory (default: `/var/www/html`)
- `MYSQL_DATABASE`: Database name (default: `app_db`)
- `MYSQL_USER`: Database user (default: `dev`)
- `MYSQL_PASSWORD`: Database password (default: `devpassword`)
- `MYSQL_ROOT_PASSWORD`: MariaDB root password (default: `rootpassword`)
- `SSH_PASSWORD`: Password for SSH access (default: `p`)
- `SSH_PORT`: External port for SSH access (default: `5555`)

### Directory Structure

- `config/`: Configuration files for services
  - `php-recommended.ini`: PHP configuration
  - `apcu.ini`: APCu cache settings
  - `000-default.conf`: Apache virtual host configuration
  - `nginx.conf`: Nginx configuration
  - `mariadb/`: MariaDB initialization scripts
  - `ssh-init.sh`: SSH initialization script

## Usage Examples

### Deploying a PHP Application

1. Place your PHP application files in a directory that will be mounted to the container:

   ```yaml
   volumes:
     - ./your-app:/var/www/html
   ```

2. Restart the containers:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

### Adding Custom PHP Extensions

Modify the Dockerfile to add more extensions:

```dockerfile
RUN docker-php-ext-install [extension-name]
```

### Database Management

Connect to the database:

```bash
docker-compose exec mariadb mysql -u dev -p
```

## Volumes

- `app_data`: Application files
- `mariadb_data`: MariaDB data
- `redis_data`: Redis data
- `elasticsearch_data`: Elasticsearch data
- `ssh_config`, `ssh_host_keys`: SSH configuration

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
