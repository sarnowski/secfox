#!/bin/sh

echo "[secfox] setting up profile..."
mkdir -p $HOME/.mozilla/firefox/secfox
cat > $HOME/.mozilla/firefox/profiles.ini << "EOF"
[General]
StartWithLastProfile=1

[Profile0]
Name=secfox
IsRelative=1
Path=secfox
EOF

if [ -f $HOME/user.js ]; then
	echo "[secfox] initializing user preferences..."
	cp $HOME/user.js $HOME/.mozilla/firefox/secfox
fi

echo "[secfox] starting firefox..."
exec firefox -P secfox -no-remote -no-xshm
