#!/bin/sh

# test for the docker binary, ubuntu ships with "docker.io"
DOCKER=docker
which docker.io 2>&1 >/dev/null
[ $? -eq 0 ] && DOCKER=docker.io

# test if we require root
$DOCKER ps >/dev/null 2>/dev/null
reqroot=$?

# switch to root if necessary
if [ $reqroot -ne 0 ] && [ $(id -u) -ne 0 ]; then
	echo "Requiring root; switching..."
	sudo $0 $*
	exit $?
fi

# basics
cd $(dirname $0)
version=$(git describe --tags)
[ -z "$version" ] && version="unknown"
echo "Building version: $version"

# build everything
$DOCKER build -rm=true -t="sarnowski/secfox:$version" .
