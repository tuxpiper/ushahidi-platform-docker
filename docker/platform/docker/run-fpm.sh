#!/bin/sh

exec /usr/bin/php-fpm -O -R -F -y /var/www/docker/php-fpm.conf
