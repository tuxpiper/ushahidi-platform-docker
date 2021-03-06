#!/bin/bash

BASEDIR=`dirname $0`

# Useful environment variables
#   - ENGINE_FQDN : hostname to reach docker engine and, once it's deployed, the platform
#   - PORT : port by which the platform should be available
#   - MYSQL_ROOT_PASSWORD
#   - MYSQL_DATABASE
#   - MYSQL_USER
#   - MYSQL_PASSWORD

#

set -e

FATAL() { code=$1; shift 1; echo "ERROR: $*"; exit $code; }

if [ -f $BASEDIR/.env ]; then
  source $BASEDIR/.env
fi

# Check requisites
if ! which docker-compose > /dev/null 2>&1; then
  FATAL 1 "docker-compose is required" 
fi
if ! which docker > /dev/null 2>&1; then
  FATAL 1 "docker is required" 
fi

fetch_ushahidi() {
  if [ ! -d $BASEDIR/.src ]; then
    mkdir $BASEDIR/.src
  fi
  if [ ! -f $BASEDIR/.src/platform.tgz ]; then
    curl -L -Ss https://github.com/ushahidi/platform/archive/master.tar.gz > $BASEDIR/.src/platform.tgz
  fi
  if [ ! -f $BASEDIR/.src/platform-client.tgz ]; then
    curl -L -Ss https://github.com/ushahidi/platform-client/archive/master.tar.gz > $BASEDIR/.src/platform-client.tgz
  fi
}

prep_build_tree() {
  pkg=$1  # name of the package

  if [ ! -d $BASEDIR/.build ]; then
    mkdir $BASEDIR/.build
  fi
  # -- Empty dir
  if [ -d $BASEDIR/.build/${pkg} ]; then
    rm -fr $BASEDIR/.build/${pkg}
  fi
  mkdir $BASEDIR/.build/${pkg}
  # these things are usually packed inside a folder called platform-master or something
  subfolder=`tar tfz $BASEDIR/.src/${pkg}.tgz | head -1 | cut -f 1 -d /`
  tar -xz -C $BASEDIR/.build/${pkg} -f $BASEDIR/.src/${pkg}.tgz
  # the source will be in "src" folder
  ( cd $BASEDIR/.build/${pkg}; mv $subfolder src )
  # sometimes an output folder comes handy
  mkdir $BASEDIR/.build/${pkg}/out
  # copy our docker stuff next to it
  cp -a $BASEDIR/docker/${pkg}/* $BASEDIR/.build/${pkg}
  cp -a $BASEDIR/docker/${pkg}/.[a-zA-Z]* $BASEDIR/.build/${pkg} 
}

build_mysql() {
  ( cd docker/mysql && docker build -t tuxpiper/ushahidi-platform-mysql:latest . )
}

build_nginx() {
  ( cd docker/nginx && docker build -t tuxpiper/ushahidi-platform-nginx:latest . ) 
}

build_platform() {
  if [ -z "$GITHUB_TOKEN" ]; then
    FATAL 1 "GITHUB_TOKEN environment variable required to build the platform";
  fi
  export GITHUB_TOKEN
  (
    cd $BASEDIR/.build/platform
    docker build -t tuxpiper/ushahidi-platform:latest --build-arg GITHUB_TOKEN=${GITHUB_TOKEN} .
  )
}

build_platform_client() {
  (
    cd $BASEDIR/.build/platform-client
    ./build.sh $1
  )
}

generate_compose_file() {
  # Try to detect host where docker is running, for the URL
  ENGINE_HOST=${ENGINE_FQDN}
  if [ -z "$ENGINE_HOST" ]; then
    ENGINE_HOST=`bash -c set | grep DOCKER_HOST | grep '=tcp://' | sed -E 's%.*tcp://([0-9\.]+):.*%\1%'`
  fi
  if [ -z "$ENGINE_HOST" ]; then
    echo "- Not sure what your docker machine is, will assume 'localhost'"
    ENGINE_HOST=localhost
  fi
  CONTAINER_PORT=${PORT:-8000}
  export ENGINE_HOST CONTAINER_PORT
  #
  # Read and patch
  f=$BASEDIR/docker/docker-compose.run.yml
  eval "cat <<< \"$(<$f)\"" > $BASEDIR/docker-compose.yml
}

ping_instance() {
  local k=0; while [ "$k" -lt "60" ]; do
    if curl -f -m 2 http://${ENGINE_HOST}:${CONTAINER_PORT}/api/v3/config/site > /dev/null 2>&1 ; then
      echo "Instance contacted"
      break
    fi
    k=$((k + 1))
    sleep 1
  done
  echo;
  [ "$k" -lt "60" ]
}

# Main
case "$1" in
  build)
    fetch_ushahidi
    prep_build_tree platform
    prep_build_tree platform-client
    build_mysql
    build_nginx
    build_platform
    PACKAGER=docker build_platform_client tuxpiper/ushahidi-platform-client:latest
    ;;
  run)
    echo "- Configuring your environment ..."
    generate_compose_file
    echo
    echo "- Bringing up services ..."
    docker-compose up -d
    echo
    echo "- Waiting for your instance to be available ..."
    if ping_instance; then
      echo "Congratulations! You can now access your Ushahidi instance at"
      echo "  http://${ENGINE_HOST}:${CONTAINER_PORT}"
      echo
      echo "The default credentials are admin / admin"
      echo
    else
      echo "Oh no! Something went wrong. Please try another install method from"
      echo "  https://www.ushahidi.com/support/install-ushahidi"
    fi
    ;;
  tarball)
    # Build single tarball release:
    #
    # platform-client-root/
    #    ...
    #    api/  <-- platform-client project
    #
    fetch_ushahidi
    prep_build_tree platform
    prep_build_tree platform-client
    # build the client
    PACKAGER=tarball build_platform_client build.tgz
    [ ! -f $BASEDIR/.build/platform-client/out/build.tgz ] && FATAL 1 "platform-client build failed!"
    # put together package contents in tarball folder
    mkdir -p $BASEDIR/.build/tarball/client $BASEDIR/.build/tarball/api
    tar -C $BASEDIR/.build/tarball/client -xz -f $BASEDIR/.build/platform-client/out/build.tgz
    cp -pr $BASEDIR/.build/platform/src/* $BASEDIR/.build/tarball/api
    cp -pr $BASEDIR/docker/tarball/* $BASEDIR/.build/tarball
    tar -C $BASEDIR/.build/tarball -cz -f $BASEDIR/.build/tarball.tgz .
    ;;
  *)
    FATAL 1 "$0 build|run|tarball"
    ;;
esac
