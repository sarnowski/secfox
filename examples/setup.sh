#!/bin/sh

# reset path
cd $(dirname $0)/..

# create structure
mkdir -p config

# copy over stuff
cp examples/user.defaults.js config/user.js
cp -r examples/searchplugins config
