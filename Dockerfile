FROM php:7.2-fpm-alpine

ADD ssh/ /root/.ssh/
ADD composer /usr/local/bin/
RUN chmod 600 /root/.ssh/id_rsa
ADD run.sh /

RUN sed -i "s/http:\/\/dl-cdn.alpinelinux.org/https:\/\/mirrors.aliyun.com/g" /etc/apk/repositories
RUN apk update \ 
&& apk add --no-cache nginx \ 
&& apk add tzdata \
&& ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& mkdir /run/nginx \ 
&& adduser -D -g 'www' www \
&& chown -R www:www /var/lib/nginx \
&& chown -R www:www /var/www/html 
WORKDIR /var/www/html
ADD nginx.conf /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf

RUN apk add --no-cache --virtual .build-deps \
    libmcrypt-dev \
    libmemcached-libs \
    curl-dev \
    zlib 
	
RUN set -ex \
&& docker-php-ext-install opcache iconv pdo pdo_mysql mysqli
		
ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev

RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
    && apk add --no-cache --update --virtual .memcached-deps $MEMCACHED_DEPS \
    && pecl install redis \
    && pecl install memcached \
    && pecl install yaf \
    && pecl install yar \
	&& pecl install mcrypt-1.0.3 \
	&& docker-php-ext-enable mcrypt \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable memcached \
    && docker-php-ext-enable yaf \
    && docker-php-ext-enable yar \
	&& composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \
    && rm -rf /usr/share/php \
    && rm -rf /tmp/* \
    && apk del .memcached-deps .phpize-deps
	
RUN apk update \
        && apk add npm \
        && npm install -g pm2

ADD demo/ ./
RUN composer install --no-dev -o
COPY demo/docker/pm2/apps.json /etc/pm2/apps.json
COPY demo/docker/crontab/root /etc/crontabs/root

EXPOSE 80
ENTRYPOINT ["/run.sh"]