#!/bin/sh

# script dir
dir=$(dirname $0)

# test if we are root
isroot=$(id -u)

# test if we require root
docker ps >/dev/null 2>/dev/null
reqroot=$?

# require root
if [ $reqroot -ne 0 ] && [ $isroot -ne 0 ]; then
	echo "Requiring root; switching to privileged mode..."
	sudo $0 $(id -un) $*
	exit $?
fi

# save user if necessary
if [ $isroot -eq 0 ]; then
	user=$1
	shift
fi

echo "[secfox] session starting..."

# have an ssh key?
key=$dir/id_rsa
if [ ! -f $key ]; then
	echo "[secfox] setting up access:"
	ssh-keygen -q -t rsa -f $dir/id_rsa || exit 1
	if [ $isroot -eq 0 ]; then
		chown $user $key
		chown $user ${key}.pub
	fi
fi
pubkey=$(cat ${key}.pub)

# run new container if necessary
echo "[secfox] starting container..."
version=$(git describe --tags)
[ -z "$version" ] && version="unknown"
cont=$(docker run -d -p 22 -t sarnowski/secfox:$version "$pubkey")
if [ -z "$cont" ]; then
	echo "[secfox] couldn't start secfox!" >&2
	exit 1
fi

echo "[secfox] searching port..."
port=$(docker inspect $cont | grep "HostPort" | head -n 1 | sed -E 's/.*"HostPort": "(.+)".*/\1/')
if [ ! -z "$(echo $port | grep "HostPort")" ]; then
	echo "[secfox] couldn't find port of secfox!" >&2
	docker kill $cont >/dev/null
	docker rm $cont >/dev/null
	exit 1
fi

echo "[secfox] waiting for container to come up..."
counter=0
while [ true ]; do
	ssh -o StrictHostKeychecking=no -i $key -p $port secfox@127.0.0.1 -C echo "[secfox] connected"
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

if [ -f $dir/user.js ]; then
	echo "[secfox] uploading user preferences..."
	scp -o StrictHostKeychecking=no -i $key -P $port $dir/user.js secfox@127.0.0.1: || exit 1
fi

echo "[secfox] starting firefox..."
ssh -o StrictHostKeychecking=no -i $key -p $port -X secfox@127.0.0.1 -C /secfox/firefox.sh || exit 1

# kill container
echo "[secfox] killing container..."
docker kill $cont >/dev/null
docker rm $cont >/dev/null

echo "[secfox] session closed."
