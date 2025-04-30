#!/bin/bash
set -e

# Make sure Apache is configured to listen on port 8080
if ! grep -q "Listen 8080" /etc/apache2/ports.conf; then
    sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf
fi

# Start Apache in background
apache2ctl -k start

# Wait a moment for Apache to fully start
sleep 2

# Start Nginx in foreground
echo "Starting Nginx..."
exec nginx -g 'daemon off;'

# Display configuration info
echo "Server is running with Apache + Nginx (reverse proxy)"

exec "$@"
