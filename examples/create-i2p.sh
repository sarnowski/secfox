#!/bin/sh
cd $(dirname $0)/..

if [ -d config ]; then
	echo "'config' directory already exists"
	exit 1
fi

echo -n "I2P router IP: "
read IP
echo -n "I2P router port: "
read port

if [ -z "$IP" ] || [ -z "$port" ]; then
	echo "You have to provide all informations."
	exit 1
fi

examples/create.sh config

cat examples/firefox/user.*.js > config/firefox/user.js
cp examples/init.proxy.sh config/init.sh
cp examples/teardown.downloads.sh config/teardown.sh

sed -i "s/192.168.1.1/$IP/g" config/init.sh
sed -i "s/8080/$port/g" config/init.sh

sed -i "s/192.168.1.1/$IP/g" config/firefox/user.js
sed -i "s/8080/$port/g" config/firefox/user.js
sed -i "s/DuckDuckGo/I2P Forum/g" config/firefox/user.js
