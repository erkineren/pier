#!/bin/bash
set -e

# Make sure Apache gets the environment variable
echo "SetEnv APP_PUBLIC_PATH /var/www/html" >/etc/apache2/conf-enabled/app-env.conf

# Start Nginx
service nginx start

# Display configuration info
echo "Apache document root: /var/www/html"

exec "$@"
