#!/bin/bash

# This script is run from inside the builder container in order to generate the built image
# with the web app files

set -ex

if [ -z "$1" ]; then
  echo "ERROR! please provide a destination for the generated image"
  exit 1
fi

DEST=$1
PACKAGER=${PACKAGER:-docker}

# Bring into the container filesystem the app source files
echo "INFO updating with files from local app"
rsync -ar --exclude=.git --exclude=node_modules/** /var/build/* ./

# convert git dependency URLs to plain github references
sed -i -e 's%git://github.com/%%' -e 's%git+https://github.com/%%' package.json

echo "INFO building app files"

# Use this easily 
export BACKEND_URL='http://change.me.on.deploy'

# Build
/usr/local/bin/npm install
/usr/local/bin/gulp build

clone_for_package() {
  temp_image_dir=$(mktemp -d)
  cp -ar server/www ${temp_image_dir}/
  rm -f $temp_image_dir/www/.gitignore
}

# Package the application into a docker image in the configured docker host
package_docker() {
  echo "INFO packaging docker image with built app (on /var/app of the image fs)"
  clone_for_package
  pushd $temp_image_dir

  if [ -z "$DOCKER_HOST" ]; then
    echo "ERROR! please provide a DOCKER_HOST environment variable so this container can build the image"
    exit 1
  fi

  docker ps &>/dev/null && echo "INFO docker connection works"

  cat > Dockerfile <<EOF
FROM tianon/true
MAINTAINER David Losada Carballo "davidlosada@ushahidi.com"

ADD www /var/app
EOF

  docker build -t $1 .

  popd
}

# Package the built application into a tar file
package_tarball() {
  echo "INFO packaging tarball image with built app"
  clone_for_package
  pushd $temp_image_dir/www

  tar -czv -f $BUILD_OUT_DIR/$1 .

  popd
}

case $PACKAGER in
  docker)
    package_docker $DEST
    ;;
  tarball)
    package_tarball $DEST
    ;;
  *)
    echo "Unknown packager: $PACKAGER !!!"
    exit 1
    ;;
esac
