FROM node:0.12

COPY platform-client /var/app
WORKDIR /var/app

RUN sed -i -e "s%git://github.com/%%" -e "s%git+https://github.com/%%" package.json

RUN npm install -g gulp@3.9.0 gulp-notify@2.2.0 grunt-cli@0.1.13
RUN npm install
RUN gulp build

CMD [ "npm", "start" ]