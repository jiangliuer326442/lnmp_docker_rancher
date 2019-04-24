# lnmp docker:

> 使用`rancherup -d -s NewLetsChatApp`命令直接运行即可生成ｌｎｍｐ环境

## nginx:

基于nginx:alpine,default.conf修改如下，位置：/etc/nginx/conf.d/default.conf

```
    location ~ .php$ {
        #root           /usr/share/nginx/html;
        root           /var/www/html;   # `这个配置 用 php-fmp 镜像 容器中的 PHP 根目录地址  切记这个不是 nginx web根目录地址 这个问题折腾了我好久`
        fastcgi_pass   phpfpm:9000;  # 修改这个地址为 phpfpm 容器的名称  我的容器名称就是 phpfmp
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
```

## mysql:

使用mysql:5.7镜像，

## php-fpm:

基于hub.c.163.com/library/php:fpm-alpine，具体实现参照Dockerfile，集成yaf,yar,memcache,redis等

```
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
```

