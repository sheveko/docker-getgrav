FROM php:7.4-apache

COPY pseudo-cron.sh docker-entrypoint.sh /usr/local/bin/

RUN set -ex \
    && apt-get update && apt-get install -y \
        $PHPIZE_DEPS \
        unzip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libyaml-dev \
        libzip-dev \
    && docker-php-ext-install opcache \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-install -j$(nproc) zip \
    && pecl install apcu \
    && pecl install yaml \
    && docker-php-ext-enable apcu yaml \
    && docker-php-source delete \
    && a2enmod rewrite expires \
    && apt-get remove -y $PHPIZE_DEPS \
    && apt-get purge -y --auto-remove -o 'APT::AutoRemove::RecommendsImportant=false;' \
    && apt-get autoremove -y --purge && apt-get autoclean -y && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && chmod +x /usr/local/bin/pseudo-cron.sh

COPY 10-php-recommended.ini 20-error-logging.ini /usr/local/etc/php/conf.d/

ENV GRAV_VERSION=1.6.23
ENV GRAV_SHASUM=86f6134c163bacce117d6a26a2adb743a479277596cbfe419553b04386d6c9f1
RUN curl -o grav-admin.zip -SL https://getgrav.org/download/core/grav-admin/${GRAV_VERSION} \
    && echo "$GRAV_SHASUM grav-admin.zip" | sha256sum --check --status \
    && unzip grav-admin.zip \
    && rm grav-admin.zip \
    && find /var/www/html/grav-admin -type f | xargs chmod 664 \
    && find /var/www/html/grav-admin/bin -type f | xargs chmod 775 \
    && find /var/www/html/grav-admin -type d | xargs chmod 775 \
    && find /var/www/html/grav-admin -type d | xargs chmod +s \
    && mv /var/www/html/grav-admin /usr/src/ \
    && chown -R www-data:www-data /var/www

EXPOSE 80

VOLUME [ "/var/www/html" ]
VOLUME [ "/usr/local/etc/php/conf.d/" ]

WORKDIR /var/www

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

CMD [ "apache2-foreground" ]
