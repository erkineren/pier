#!/bin/bash

# Set working directory in shell configs
echo 'cd /var/www/html' >>/config/.bashrc
echo 'cd /var/www/html' >>/config/.profile

# Create symbolic link for convenience
ln -sf /var/www/html /config/app

# Set proper permissions
chmod 644 /config/.bashrc /config/.profile

# Since we're using PUID=33 (www-data), we need to update the user reference
# User is now www-data (33) instead of abc
chown "${PUID}:${PGID}" /config/.bashrc /config/.profile

# Ensure the SSH user can write to the html directory
chmod 775 /var/www/html
chmod g+w /var/www/html

# Set welcome message
echo "Welcome to the PHP infrastructure! You are now in the application directory." >/etc/motd
chmod 644 /etc/motd

echo "SSH initialization complete."
