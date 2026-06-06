FROM php:8.2-apache

# Instal ekstensi Linux dan PHP yang dibutuhkan Laravel & Supabase
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-install pdo pdo_pgsql pgsql zip

# Aktifkan mod_rewrite Apache untuk routing Laravel
RUN a2enmod rewrite

# Ubah root direktori Apache ke folder public Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Instal Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Atur folder kerja
WORKDIR /var/www/html

# Copy seluruh file proyek ke dalam server
COPY . /var/www/html

# Instal dependensi Laravel (mengabaikan mode dev)
RUN composer install --no-dev --optimize-autoloader

# Berikan hak akses folder agar Laravel bisa menyimpan cache & session
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Jalankan server Apache
CMD ["apache2-foreground"]
