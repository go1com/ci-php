FROM php:7.2-alpine

ENV MODULES_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev libmcrypt-dev libxml2-dev icu-dev
RUN apk add --no-cache --update libmemcached-libs zlib icu-libs libmcrypt curl bash git graphviz openssh-client \
    && set -xe \
    && apk add --no-cache --update --virtual .phpize-deps $PHPIZE_DEPS \
    && apk add --no-cache --update --virtual .modules-deps $MODULES_DEPS \
    && pecl install memcached xdebug \
    && docker-php-ext-enable memcached xdebug \
    && docker-php-ext-install -j $(getconf _NPROCESSORS_ONLN) bcmath pdo_mysql intl soap pcntl \
    && rm -rf /usr/share/php7 \
    && rm -rf /tmp/* \
    && apk del .modules-deps .phpize-deps \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer global require phpunit/phpunit:* \
    && composer global require phpmetrics/phpmetrics:* \
    && composer global require go1/deploy-helper:* \
    && ln -s ~/.composer/vendor/bin/phpunit /usr/local/bin/phpunit \
    && ln -s ~/.composer/vendor/bin/phpmetrics /usr/local/bin/phpmetrics \
    && ln -s ~/.composer/vendor/bin/deploy-helper /usr/local/bin/deploy-helper \
    && echo 'date.timezone = UTC' >> /usr/local/etc/php/conf.d/tz.ini
