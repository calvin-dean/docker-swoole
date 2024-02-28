FROM php:7.4.33-cli

LABEL Author="Calvin Dean"
LABEL E-mail="23177804@qq.com"
LABEL GitBlob="https://calvin-dean.github.io"
LABEL BaseImage="php:7.4.24-cli"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM            xterm-color

ARG DEV_MODE
ENV DEV_MODE $DEV_MODE

COPY ./rootfilesystem/ /
COPY ./swoole-loader/swoole_loader74.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/swoole_loader74.so

EXPOSE 8000 8080

RUN set -ex \
    &&curl -sfL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    &&chmod +x /usr/bin/composer \
    &&composer self-update 2.1.9 \
    &&apt-get update \
    &&apt-get install -y \
        libcurl4-openssl-dev \
        libssl-dev \
        supervisor \
        unzip \
        autoconf \
        zlib1g-dev \
        --no-install-recommends \
    &&install-swoole.sh 4.8.0 \
        --enable-http2   \
        --enable-mysqlnd \
        --enable-openssl \
        --enable-sockets --enable-swoole-curl --enable-swoole-json \
    &&mkdir -p /var/log/supervisor \
    &&rm -rf /var/lib/apt/lists/* \
            $HOME/.composer/*-old.phar \
            /usr/bin/qemu-*-static\
    && pecl update-channels \
    && pecl install redis-stable \
    && pecl install pecl/propro \
    # && pecl install pecl_http-3.3.0 \
    && docker-php-ext-enable propro \
    && docker-php-ext-enable raphf \
    && docker-php-ext-install bcmath \
    && docker-php-ext-enable bcmath \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-enable pdo_mysql \
    && docker-php-ext-enable swoole_loader74
    
ENTRYPOINT ["/entrypoint.sh"]
CMD []

WORKDIR "/var/www/"
