FROM alpine:3.2

RUN apk update && \
    apk add curl php-fpm php-openssl php-gd php-json php-phar php-curl \
                 php-mcrypt php-mysqli php-pdo php-ctype php-dom \
                 php-pdo_mysql bash && \
    rm -rf /var/cache/apk/*

RUN curl -sS https://getcomposer.org/installer | \
      php -- --install-dir=/usr/local/bin --filename=composer

ARG GITHUB_TOKEN
RUN composer config -g github-oauth.github.com $GITHUB_TOKEN

COPY src /var/www

WORKDIR /var/www

RUN ./bin/update --no-migrate --no-interaction

COPY docker /root/docker

EXPOSE 9000

CMD [ "/bin/bash", "/root/docker/run-fpm.sh" ]
