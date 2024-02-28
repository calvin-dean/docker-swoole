---
title: Docker-Swoole
date: 2024-02-28 13:51:16
tags:
---

#### Step1:Docker拉取php镜像

```shell
docker pull php:7.4.33-cli
```

#### Step2:拉取docker-swoole的github的仓库,地址为https://github.com/swoole/docker-swoole.git

```shell
git clone https://github.com/swoole/docker-swoole.git
```

#### Step3:创建自己制作Docker镜像的目录,我的叫php74.swoole48.redis

```shell
mkdir php74.swoole48.redis
```

#### Step4:复制/移动docker-swoole的rootfilessystem目录至docker镜像目录下

```shell
cp/mv ./docker-swoole/rootfilessystem ./php74.swoole48.redis/
```

#### Step5:(安装swoole-loader可选)网上找到swoole-loader的so,没有的话可以直接拉取我的仓库:https://github.com/calvin-dean/docker-swoole.git

```shell
git clone https://github.com/calvin-dean/docker-swoole-calvin.git
```

#### Step7:复制swoole-loader中的so/dll到docker镜像目录下

```
cp/mv ./docker-swoole-calvin/swoole-loader ./php74.swoole48.redis/
```

#### Step7:进入php74.swoole48.redis目录并创建Dockerfile

```shell
cd php74.swoole48.redis && touch Dockerfile
```

#### Step8:编辑Dockerfile如下

```Dockerfile
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
    && docker-php-ext-enable propro \
    && docker-php-ext-enable raphf \
    && docker-php-ext-install bcmath \
    && docker-php-ext-enable bcmath \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-enable pdo_mysql \
    #如果不需要swoole-loader下一行可删除
    && docker-php-ext-enable swoole_loader74
    
ENTRYPOINT ["/entrypoint.sh"]
CMD []

WORKDIR "/var/www/"

```

#### Step9:创建docker镜像(尽量创建自己的dockerhub的镜像)

```shell
docker build -t eighteight/swoole48-php74:1.0 .
```
