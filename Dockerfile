FROM php:7
MAINTAINER sang@go1.com.au

# Install modules
RUN apt-get update && apt-get install -y -qq libmemcached-dev libmcrypt-dev libicu-dev libxml2-dev libssl-dev curl git-core unzip \
    && git clone https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached
    && cd /usr/src/php/ext/memcached && git checkout -b php7 origin/php7 \
    && phpize && ./configure && make && make install && docker-php-ext-enable memcached \
    && docker-php-ext-install bcmath mcrypt pdo_mysql opcache mbstring intl soap pcntl && apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable and configure xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Install tools (phpunit, xdebug, composer)
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer
RUN composer global require phpunit/phpunit:* && composer global require phing/phing:* && ln -s ~/.composer/vendor/bin/phpunit /usr/local/bin/phpunit && ln -s ~/.composer/vendor/bin/phing /usr/local/bin/phing
RUN curl -O http://files.drush.org/drush.phar && chmod +x drush.phar && mv drush.phar /usr/local/bin/drush

# Setup env
RUN echo 'date.timezone = UTC' >> /usr/local/etc/php/php.ini
