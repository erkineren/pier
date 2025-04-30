#!/bin/bash
set -e

echo "Configuring the server..."

# Make sure Apache is configured to listen on port 8080
if ! grep -q "Listen 8080" /etc/apache2/ports.conf; then
    sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf
    echo "Apache configured to use port 8080"
fi

# Start Apache in background
echo "Starting Apache in background..."
apache2ctl -k start
if [ $? -eq 0 ]; then
    echo "Apache started successfully on port 8080"
else
    echo "Failed to start Apache"
    exit 1
fi

# Wait a moment for Apache to fully start
echo "Waiting for Apache to initialize..."
sleep 2

# Display configuration info
echo "Server is running with Apache (port 8080) + Nginx (port 80) as reverse proxy"
echo "Document root: /var/www/html"

# Start Nginx in foreground
echo "Starting Nginx on port 80..."
# Using daemon off to keep the container running

if [ "$1" = 'apache2-foreground' ]; then
    nginx -g 'daemon off;'
else
    nginx
    exec "$@"
fi

echo "Server is running"
