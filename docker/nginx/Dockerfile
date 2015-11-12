FROM alpine:3.2
MAINTAINER David Losada Carballo "davidlosada@ushahidi.com"

RUN apk update && \
    apk add nginx && \
    rm -rf /var/cache/apk/*

COPY nginx.conf /etc/nginx/nginx.conf
COPY site.conf /etc/nginx/conf.d/site.conf
COPY fastcgi_params.conf /etc/nginx/fastcgi_params.conf
COPY start.sh /root

EXPOSE 80

CMD ["/bin/sh", "/root/start.sh"]
