 FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    zip \
    curl \
    unzip \
    git \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Install Node.js and npm
RUN apt-get install -y npm

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy existing application directory contents
COPY . /var/www/html

# Copy .env file and generate key
COPY .env.example .env

# Set file permissions
RUN chown -R www-data:www-data /var/www/html

# Switch to www-data
USER www-data

# Install PHP dependencies
RUN composer install --no-dev 

# RUN php artisan key:generate
RUN php artisan key:generate

# Switch back to root
USER root

# Install NPM 
RUN npm install -g vite
RUN npm install -f
RUN npm run dev

# Expose port 8000 and start php server
EXPOSE 8000

