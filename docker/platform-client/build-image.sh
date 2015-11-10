#!/bin/bash

# This script is run from inside the builder container in order to generate the built image
# with the web app files

set -ex

if [ -z "$1" ]; then
	echo "ERROR! please provide an image tag to assign to the generated image"
	exit 1
fi

if [ -z "$DOCKER_HOST" ]; then
	echo "ERROR! please provide a DOCKER_HOST environment variable so this container can build the image"
	exit 1
fi

docker ps &>/dev/null && echo "INFO docker connection works"

echo "INFO updating with files from local app"
rsync -ar --delete-after --exclude=.git --exclude=node_modules/** /var/build/* /var/build.local/

cd /var/build.local

# convert git dependency URLs to plain github references
sed -i -e 's%git://github.com/%%' -e 's%git+https://github.com/%%' package.json

echo "INFO building app files"
/usr/local/bin/npm install
/usr/local/bin/gulp build

echo "INFO packaging docker image with built app (on /var/app of the image fs)"
temp_image_dir=$(mktemp -d)
cp -ar server/www ${temp_image_dir}/

pushd $temp_image_dir

rm -f www/.gitignore

cat > Dockerfile <<EOF
FROM busybox
ADD www /var/app
EOF

docker build -t $1 .

popd
