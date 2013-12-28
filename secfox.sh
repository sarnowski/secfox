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

# start firefox!
echo "[secfox] connecting to container..."
cmd="ssh -i $key -X -p $port -o StrictHostKeychecking=no secfox@127.0.0.1"
failed=0
counter=0
while [ true ]; do
	if [ $isroot -eq 0 ]; then
		sudo -u $user $cmd
		failed=$?
	else
		$cmd
		failed=$?
	fi
	[ $failed -eq 0 ] && break

	counter=$(($counter + 1))
	[ $counter -gt 5 ] && break
	sleep 1
done
if [ $failed -ne 0 ]; then
	echo "[secfox] failed to connect to container:"
	docker logs $cont | tail -n 20
fi

# kill container
echo "[secfox] killing container..."
docker kill $cont >/dev/null
docker rm $cont >/dev/null

echo "[secfox] session closed."
