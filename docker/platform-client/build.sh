#!/bin/bash

if [ -z "$1" ]; then
	echo "ERROR! please provide an image tag to assign to the generated image"
	exit 1
fi

if [ -z "$DOCKER_CERT_PATH" ]; then
	export DOCKER_CERT_PATH='.'
fi	

docker-compose build
docker-compose run builder /usr/local/bin/build-image.sh $1
