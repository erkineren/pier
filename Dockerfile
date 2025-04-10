FROM php:8.1-apache

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
    openssh-server \
    rsync \
    nano \
    vim

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
RUN a2enmod rewrite headers expires env

# SSH Server setup
RUN mkdir -p /var/run/sshd \
    && echo 'root:root' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config \
    && sed -i 's/#GatewayPorts no/GatewayPorts yes/' /etc/ssh/sshd_config \
    && sed -i 's/#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config \
    && sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding yes/' /etc/ssh/sshd_config

# Create appuser for SSH access with www-data permissions
RUN useradd -m -d /var/www appuser \
    && echo "appuser:${SSH_PASSWORD:-password}" | chpasswd \
    && usermod -aG www-data appuser \
    && echo 'appuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && chown -R appuser:www-data /var/www/html

# Set up the working directory
WORKDIR /var/www/html

# Create PHP log directory
RUN mkdir -p /var/log/php \
    && touch /var/log/php/php_errors.log \
    && chown www-data:www-data /var/log/php /var/log/php/php_errors.log \
    && chmod 755 /var/log/php \
    && chmod 664 /var/log/php/php_errors.log

# Create a basic index.html for healthcheck (will be overridden by mounted app files)
RUN echo '<!DOCTYPE html><html><body><h1>Server is running</h1><p>Infrastructure is ready.</p></body></html>' > /var/www/html/index.html \
    && chmod 644 /var/www/html/index.html \
    && chown www-data:www-data /var/www/html/index.html

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set up entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set proper permissions for the application directory
RUN chown -R www-data:www-data /var/www/html/ \
    && chmod -R 775 /var/www/html/ \
    && chmod g+s /var/www/html/

EXPOSE 80 22

COPY ssh-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/ssh-entrypoint.sh

ENTRYPOINT ["ssh-entrypoint.sh"]
CMD ["apache2-foreground"] 