#使用国内网易镜像可以加快构建速度
FROM hub.c.163.com/library/php:fpm-alpine
#FROM php:fpm-alpine

MAINTAINER Alu alu@xdreport.com

#国内repo源，让本地构建速度更快。
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

RUN apk add --no-cache --virtual .build-deps \
	libmcrypt-dev \
	libmemcached-libs \
	curl-dev \
	zlib

#添加php源码中的扩展，添加mysqli,pdo-mysql,opcache,gettext,mcrypt等扩展
RUN set -ex \
        && docker-php-ext-install opcache iconv mcrypt pdo pdo_mysql mysqli

#memcached
ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev

#redis属于pecl扩展，需要使用pecl命令来安装，同时需要添加依赖的库
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
    	&& apk add --no-cache --update --virtual .memcached-deps $MEMCACHED_DEPS \
        && pecl install redis \
    	&& pecl install memcached \
	&& pecl install yaf \
	&& pecl install yar \
        && docker-php-ext-enable redis \
	&& docker-php-ext-enable memcached \
	&& docker-php-ext-enable yaf \
	&& docker-php-ext-enable yar \
    	&& rm -rf /usr/share/php \
    	&& rm -rf /tmp/* \
        && apk del .memcached-deps .phpize-deps

