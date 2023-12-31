FROM php:8.2-apache

# Install required packages
RUN apt-get update && \
    apt-get install -y \
        libzip-dev \
        unzip

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Enable Apache modules
RUN a2enmod rewrite

# Set the working directory
WORKDIR /var/www/html

# Copy files
COPY . /var/www/html

# Adjust permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod -R 777 /var/www/html/storage

# Remove default Apache config
RUN rm -rf /etc/apache2/sites-available/000-default.conf

# Create virtual host configuration for Apache
RUN echo "<VirtualHost *:80> \n\
    DocumentRoot /var/www/html/public \n\
    <Directory /var/www/html/public> \n\
        AllowOverride All \n\
        Order allow,deny \n\
        Allow from all \n\
    </Directory> \n\
</VirtualHost>" > /etc/apache2/sites-available/000-default.conf

# Enable the virtual host
RUN a2ensite 000-default

# Expose port
EXPOSE 80

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# Generate Laravel application key
RUN php artisan key:generate

# Start Apache
CMD ["apache2-foreground"]
