#!/bin/sh
crond
pm2 start /etc/pm2/apps.json
php-fpm -D
# 关闭后台启动，hold住进程
nginx -g 'daemon off;'