FROM alpine:3.2
MAINTAINER David Losada Carballo <davidlosada@ushahidi.com>

RUN apk update && \
    apk add curl apache2 php-apache2 git bash \
                 php-fpm php-openssl php-gd php-json php-phar php-curl \
                 php-mcrypt php-mysqli php-pdo php-ctype php-dom \
                 php-pdo_mysql && \
    rm -rf /var/cache/apk/*

RUN curl -sS https://getcomposer.org/installer | \
      php -- --install-dir=/usr/local/bin --filename=composer

# Github token should be a build arg but docker-compose has no support yet :(
#ARG GITHUB_TOKEN
ADD .github_token /root/.github_token
RUN composer config -g github-oauth.github.com $(cat /root/.github_token)

# Copy api code
COPY ./api /platform/api
WORKDIR /platform

# Get composer dependencies
RUN cd api && ./bin/update --no-migrate --no-interaction
RUN chown -R apache:apache api/application/cache api/application/logs
COPY dist/template.htaccess /platform/api/httpdocs/.htaccess

# Copy platform client files
COPY ./client /platform/client

# Copy apache config
COPY dist/server.conf /etc/apache2/conf.d/server.conf

# Copy run script
COPY dist/run.sh /platform/run.sh

EXPOSE 80
CMD [ "/bin/bash", "/platform/run.sh" ]
