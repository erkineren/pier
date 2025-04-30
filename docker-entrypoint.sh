#!/bin/bash
set -e

echo "Configuring the server..."

# Create log directories if they don't exist
mkdir -p /var/log/apache2
mkdir -p /var/log/nginx
mkdir -p /var/log/php

# Set correct permissions for log files
touch /var/log/php/php_errors.log
chmod 666 /var/log/php/php_errors.log

# Ensure log symlinks are set up correctly
ln -sf /dev/stdout /var/log/apache2/access.log
ln -sf /dev/stderr /var/log/apache2/error.log
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log
ln -sf /dev/stderr /var/log/php/php_errors.log

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
echo "Logs are stored in /var/log and streamed to container output"
echo "-----------------------------------------------------"
echo "All logs will be displayed below:"
echo "-----------------------------------------------------"

# Setup logrotate cron job
echo "* * * * * /usr/sbin/logrotate /etc/logrotate.d/app-logs >/dev/null 2>&1" >/etc/cron.d/logrotate
chmod 0644 /etc/cron.d/logrotate
crontab /etc/cron.d/logrotate

# Start cron service
service cron start

# Start processes to show all logs
if [ "$1" = 'apache2-foreground' ]; then
    # Start Nginx in foreground
    nginx -g 'daemon off;'
else
    nginx
    exec "$@"
fi
