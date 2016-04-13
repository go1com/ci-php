FROM php:5
MAINTAINER sang@go1.com.au

# Install modules
RUN apt-get update && apt-get install -y -qq libmcrypt-dev libicu-dev libxml2-dev libssl-dev curl git-core unzip \
    && docker-php-ext-install mcrypt pdo_mysql opcache mbstring intl soap pcntl && apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable and configure xdebug
RUN pecl install xdebug mongo
RUN docker-php-ext-enable xdebug mongo
# Download mailparse
RUN pecl download mailparse-2.1.6 && tar -zxf mailparse-2.1.6.tgz && cd mailparse-2.1.6 && sed -i '/#if !HAVE_MBSTRING/c#if !HAVE_MBSTRING && false' mailparse.c && phpize && ./configure && make -j$(nproc) && make install
RUN docker-php-ext-enable mailparse
# Install tools (phpunit, xdebug, composer)
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN composer global require phpunit/phpunit:*
RUN composer global require phing/phing:*
RUN curl -O http://files.drush.org/drush.phar && chmod +x drush.phar && mv drush.phar /usr/local/bin/drush

RUN ln -s ~/.composer/vendor/bin/phpunit /usr/local/bin/phpunit
RUN ln -s ~/.composer/vendor/bin/phing /usr/local/bin/phing
# Setup env
RUN echo 'date.timezone = UTC' >> /usr/local/etc/php/php.ini