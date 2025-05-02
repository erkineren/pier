# Define build arguments
ARG PHP_VERSION=8.1
FROM php:${PHP_VERSION}-apache

# Set environment variables for user and group IDs
ENV APP_USER_ID=1000
ENV APP_GROUP_ID=1000
ENV APP_USER=appuser

# Install required dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libzip-dev \
    libmcrypt-dev \
    libicu-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    pkg-config \
    unzip \
    git \
    redis-tools \
    wget \
    curl \
    nano \
    vim \
    nginx \
    logrotate \
    gosu

# Install PHP extensions - separated to identify any problematic extensions
# First, configure and install GD
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

# Install database extensions
RUN docker-php-ext-install pdo pdo_mysql mysqli

# Install XML extensions
RUN docker-php-ext-install dom simplexml xml

# Install other extensions in smaller batches
RUN docker-php-ext-install zip intl opcache

# Install additional common extensions
RUN docker-php-ext-install mbstring exif bcmath calendar fileinfo gettext soap sockets

# Redis extension
RUN pecl install redis \
    && docker-php-ext-enable redis

# APCu extension
RUN pecl install apcu \
    && docker-php-ext-enable apcu

# Configure Apache
RUN a2enmod rewrite headers expires env proxy proxy_http remoteip
# Change Apache port from 80 to 8080
RUN sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf

# Create log directories
RUN mkdir -p /var/log/apache2 \
    && mkdir -p /var/log/nginx \
    && mkdir -p /var/log/php

# Configure Apache logs
RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

# Configure Nginx logs
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Configure PHP logs
RUN touch /var/log/php/php_errors.log && \
    chmod 666 /var/log/php/php_errors.log && \
    ln -sf /dev/stderr /var/log/php/php_errors.log

# Configure Nginx as reverse proxy
RUN rm /etc/nginx/sites-enabled/default
COPY config/nginx.conf /etc/nginx/conf.d/default.conf

# Set up logrotate
COPY config/logrotate.conf /etc/logrotate.d/app-logs

# Set up the working directory
WORKDIR /var/www/html

# Create a basic index.html for healthcheck (will be overridden by mounted app files)
RUN echo '<!DOCTYPE html><html><body><h1>Server is running</h1><p>Infrastructure is ready.</p></body></html>' > /var/www/html/index.html

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy configuration files
COPY config/php-recommended.ini /usr/local/etc/php/conf.d/php-recommended.ini
COPY config/apcu.ini /usr/local/etc/php/conf.d/apcu.ini
COPY config/000-default.conf /etc/apache2/sites-available/000-default.conf

# Set up entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"] 