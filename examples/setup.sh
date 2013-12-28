#!/bin/sh

if [ -z "$1" ]; then
	echo "Usage:  $0 <path>" >&2
	exit 1
fi

dir=$1

# reset path
cd $(dirname $0)/..

# create structure
mkdir -p $dir

# copy over stuff
cp examples/user.defaults.js $dir/user.js
cp -r examples/searchplugins $dir
