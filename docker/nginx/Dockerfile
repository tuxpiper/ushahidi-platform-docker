FROM alpine:3.2
MAINTAINER David Losada Carballo "davidlosada@ushahidi.com"

RUN apk update && \
    apk add nginx && \
    rm -rf /var/cache/apk/*

CMD ["nginx", "-g", "daemon off;"]
