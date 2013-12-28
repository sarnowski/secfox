#!/bin/sh

# application dir
dir=$(dirname $0)

# test if we are root
isroot=$(id -u)

# test if we require root
docker ps >/dev/null 2>/dev/null
reqroot=$?

# require root
if [ $reqroot -ne 0 ] && [ $isroot -ne 0 ]; then
	echo "[secfox] Requiring root; switching to privileged mode..."
	sudo $0 $(id -un) $*
	exit $?
fi

# save user if we switched
if [ $isroot -eq 0 ]; then
	user=$1
	shift
fi

# choose session
session="default"
session_dir=$dir/config
if [ ! -z "$1" ]; then
	session=$1
	session_dir=$dir/config-$session
fi

echo "[secfox] session $session starting..."

version=$(git describe --tags)
[ -z "$version" ] && version="unknown"

# create new profile directory
if [ ! -d $session_dir ]; then
	echo "[secfox] creating new configuration from examples..."
	$dir/examples/setup.sh $session_dir
	if [ $isroot -eq 0 ]; then
		chown -R $user $session_dir
	fi
fi

# have an ssh key?
key=$session_dir/id_rsa
if [ ! -f $key ]; then
	echo "[secfox] setting up access, enter a password of your choice:"
	ssh-keygen -q -t rsa -f $key || exit 1
	if [ $isroot -eq 0 ]; then
		chown $user $key
		chown $user ${key}.pub
	fi
fi
pubkey=$(cat ${key}.pub)

# image available? if not, build
if [ -z "$(docker images sarnowski/secfox | grep -E "[ \\t]$version+[ \\t]+")" ]; then
	echo "[secfox] building container $version ..."
	$dir/image/build.sh || exit 1
fi

# run new container
echo "[secfox] starting container $version ..."
cont=$(docker run -d -p 22 -t sarnowski/secfox:$version "$pubkey")
if [ -z "$cont" ]; then
	echo "[secfox] couldn't start secfox!" >&2
	exit 1
fi

# read the generated local port
echo "[secfox] searching port..."
port=$(docker inspect $cont | grep "HostPort" | head -n 1 | sed -E 's/.*"HostPort": "(.+)".*/\1/')
if [ ! -z "$(echo $port | grep "HostPort")" ]; then
	echo "[secfox] couldn't find port of secfox!" >&2
	docker kill $cont >/dev/null
	docker rm $cont >/dev/null
	exit 1
fi

# wait until sshd started
echo "[secfox] waiting for container to come up..."
counter=0
while [ true ]; do
	ssh -q -o StrictHostKeychecking=no -i $key -p $port secfox@127.0.0.1 -C echo "[secfox] connected" 2>/dev/null
	[ $? -eq 0 ] && break

	counter=$(($counter + 1))
	if [ $counter -gt 5 ]; then
		echo "[secfox] failed to connect to container!"
		docker logs $cont | tail -n 20
		docker kill $cont >/dev/null
		docker rm $cont >/dev/null
		exit 1
	fi
done
echo "[secfox] ### SSH access via:  ssh -i $dir/id_rsa -p $port secfox@127.0.0.1"

# upload configurations
echo "[secfox] uploading configurations... [$session_dir]"
scp -r -q -o StrictHostKeychecking=no -i $key -P $port $session_dir/* secfox@127.0.0.1:.mozilla/firefox/secfox/ || exit 1

# now do it!
echo "[secfox] starting firefox..."
ssh -q -o StrictHostKeychecking=no -i $key -p $port -X secfox@127.0.0.1 -C /secfox/firefox.sh || exit 1

# kill container
echo "[secfox] killing container..."
docker kill $cont >/dev/null
docker rm $cont >/dev/null

echo "[secfox] session closed."
