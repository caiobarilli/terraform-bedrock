# Dockerfile PHP 8.4 FPM para Bedrock + Sage
FROM php:8.4-fpm

########################
# Dependências do sistema
########################
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

########################
# Extensões PHP necessárias
########################
RUN docker-php-ext-install pdo_mysql mysqli zip exif pcntl bcmath

########################
# Composer
########################
ENV COMPOSER_MEMORY_LIMIT=-1
ENV COMPOSER_PROCESS_TIMEOUT=2000
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

########################
# WP-CLI
########################
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod 755 /usr/local/bin/wp
ENV PATH="/usr/local/bin:${PATH}"

########################
# php.ini customizado
########################
COPY php.ini /usr/local/etc/php/conf.d/php.ini

########################
# Criar usuário appuser (UID 1000)
########################
RUN groupadd -g 1000 appuser \
    && useradd -u 1000 -g 1000 -m appuser \
    && mkdir -p /var/www/html \
    && chown -R appuser:appuser /var/www/html

########################
# Configurar PHP-FPM para usar appuser
########################
RUN sed -i 's/www-data/appuser/g' /usr/local/etc/php-fpm.d/www.conf

########################
# Diretório de trabalho e usuário
########################
WORKDIR /var/www/html
USER appuser