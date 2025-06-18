FROM php:8.1-apache

# Cài extension
RUN apt-get update && apt-get install -y \
    zip unzip git curl libzip-dev libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif pcntl \
    && a2enmod rewrite

# Thay đổi DocumentRoot thành public/
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Cập nhật cấu hình Apache để trỏ vào thư mục public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/000-default.conf

# Copy mã nguồn Laravel vào container
WORKDIR /var/www/html
COPY . .

# Cài đặt composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Cài thư viện PHP
RUN composer install --no-dev --optimize-autoloader

# Cấp quyền cho Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 80

CMD ["apache2-foreground"]
