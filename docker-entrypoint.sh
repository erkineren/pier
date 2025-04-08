#!/bin/bash
set -e

# Set default APP_PUBLIC_PATH if not provided
if [ -z "$APP_PUBLIC_PATH" ]; then
    export APP_PUBLIC_PATH=/var/www/html
fi

# Check if APP_PUBLIC_PATH is a subdirectory of /var/www/html
if [[ "$APP_PUBLIC_PATH" != "/var/www/html" && "$APP_PUBLIC_PATH" =~ ^/var/www/html/.+ ]]; then
    # Create the directory if it doesn't exist
    mkdir -p "$APP_PUBLIC_PATH"
    # Copy index.html to the public directory if it's empty
    if [ ! "$(ls -A "$APP_PUBLIC_PATH")" ]; then
        cp /var/www/html/index.html "$APP_PUBLIC_PATH/"
    fi
fi

# Make sure Apache gets the environment variable
echo "SetEnv APP_PUBLIC_PATH ${APP_PUBLIC_PATH}" >/etc/apache2/conf-enabled/app-env.conf

# Set proper permissions for critical directories
echo "Setting proper permissions..."
chmod -R 775 /var/www/html
find /var/www/html -type d -exec chmod 775 {} \;
find /var/www/html -type f -exec chmod 664 {} \;
chown -R www-data:www-data /var/www/html

# Ensure appuser is in www-data group and can write to the directory
usermod -aG www-data appuser
chmod g+s /var/www/html # Set SGID bit to ensure new files inherit group ownership

# Display configuration info
echo "Apache document root: $APP_PUBLIC_PATH"

exec "$@"
