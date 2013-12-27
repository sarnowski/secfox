#!/bin/sh

if [ $# -ne 1 ]; then
	echo "Usage:  <ssh-key>" >&2
	exit 1
fi

# set up authentication
echo "[secfox] setting up access configuration..."

key=$1
keyfile=/secfox/home/.ssh/authorized_keys

mkdir -p $(dirname $keyfile)
chmod 0700 $(dirname $keyfile)

echo "command=\"/secfox/firefox.sh\" $key" > $keyfile
chmod 0400 $keyfile

chown -R secfox $(dirname $keyfile)

echo "[secfox] authorized informations:"
cat $keyfile

# run sshd
echo "[secfox] starting SSH daemon..."
exec /usr/sbin/sshd -e -D
