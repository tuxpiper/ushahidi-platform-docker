#!/bin/sh

/root/docker/prepare.sh

exec /usr/bin/php-fpm -O -R -F -y /root/docker/php-fpm.conf
