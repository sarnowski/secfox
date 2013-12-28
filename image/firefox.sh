#!/bin/sh

if [ -f $HOME/.mozilla/firefox/secfox/init.sh ]; then
	echo "[secfox] executing initialization steps..."
	. $HOME/.mozilla/firefox/secfox/init.sh
fi

echo "[secfox] executing firefox..."
exec firefox -P secfox -no-remote -no-xshm
