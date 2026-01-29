# syntax=docker/dockerfile:1.4

# Development stage
FROM dunglas/frankenphp:php8.3-alpine AS dev

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN install-php-extensions \
    pdo_pgsql \
    opcache \
    intl \
    zip

WORKDIR /app

COPY composer.json* composer.lock* ./
RUN composer install --prefer-dist --no-scripts --no-progress --no-interaction || true

COPY . .

RUN composer dump-autoload --optimize

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "public"]

# Production stage
FROM dunglas/frankenphp:php8.3-alpine AS prod

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN install-php-extensions \
    pdo_pgsql \
    opcache \
    intl \
    zip

# Configure PHP for production
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Configure OPcache
RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.max_accelerated_files=20000" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/opcache.ini

WORKDIR /app

# Copy composer files and install dependencies
COPY composer.json* composer.lock* ./
RUN composer install --no-dev --prefer-dist --no-scripts --no-progress --no-interaction --optimize-autoloader || composer install --no-dev --prefer-dist --no-scripts --no-progress --no-interaction --optimize-autoloader --no-plugins

# Copy application code
COPY . .

# Set production environment
ENV APP_ENV=prod

# Generate optimized autoloader
RUN composer dump-autoload --optimize --classmap-authoritative --no-dev

# Warm up cache
RUN php bin/console cache:warmup

# Set proper permissions
RUN chown -R www-data:www-data /app/var

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "public"]
