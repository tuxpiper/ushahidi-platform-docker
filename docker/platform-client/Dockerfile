FROM node:0.12

RUN apt-get update && apt-get install -y rsync && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -o /usr/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-1.9.0
RUN chmod +x /usr/bin/docker

RUN /usr/local/bin/npm install -g gulp@3.9.0 gulp-notify@2.2.0 grunt-cli@0.1.13

ADD build-image.sh /usr/local/bin/build-image.sh

CMD [ "/bin/bash", "/usr/local/bin/build-image.sh" ]
