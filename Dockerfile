FROM alpine:3.18.2

LABEL description="Simple forum software for building great communities" \
      maintainer="Magicalex <magicalex@mondedie.fr>"

ARG VERSION=v1.8.1

ENV GID=991 \
    UID=991 \
    UPLOAD_MAX_SIZE=50M \
    PHP_MEMORY_LIMIT=128M \
    OPCACHE_MEMORY_LIMIT=128 \
    DB_HOST=mariadb \
    DB_USER=flarum \
    DB_NAME=flarum \
    DB_PORT=3306 \
    FLARUM_TITLE=Docker-Flarum \
    DEBUG=false \
    LOG_TO_STDOUT=false \
    GITHUB_TOKEN_AUTH=false \
    FLARUM_PORT=8888

RUN apk add --no-progress --no-cache \
    curl \
    git \
    icu-data-full \
    libcap \
    nginx \
    php8.2 \
    php8.2-ctype \
    php8.2-curl \
    php8.2-dom \
    php8.2-exif \
    php8.2-fileinfo \
    php8.2-fpm \
    php8.2-gd \
    php8.2-gmp \
    php8.2-iconv \
    php8.2-intl \
    php8.2-mbstring \
    php8.2-mysqlnd \
    php8.2-opcache \
    php8.2-pecl-apcu \
    php8.2-openssl \
    php8.2-pdo \
    php8.2-pdo_mysql \
    php8.2-phar \
    php8.2-session \
    php8.2-tokenizer \
    php8.2-xmlwriter \
    php8.2-zip \
    php8.2-zlib \
    su-exec \
    s6 \
  && cd /tmp \
  && curl --progress-bar http://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && sed -i 's/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/' /etc/php8.2/php.ini \
  && chmod +x /usr/local/bin/composer \
  && mkdir -p /run/php /flarum/app \
  && COMPOSER_CACHE_DIR="/tmp" composer create-project flarum/flarum:$VERSION /flarum/app \
  && composer clear-cache \
  && rm -rf /flarum/.composer /tmp/* \
  && setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/nginx

COPY rootfs /
RUN chmod +x /usr/local/bin/* /etc/s6.d/*/run /etc/s6.d/.s6-svscan/*
VOLUME /etc/nginx/flarum /flarum/app/extensions /flarum/app/public/assets /flarum/app/storage/logs
CMD ["/usr/local/bin/startup"]
