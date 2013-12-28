# Example how to lock down your secfox system to only
# allow connections via your proxy.
#
#  cp examples/init.proxy.sh config/init.sh
#
#

PROXY_IP=192.168.1.1
PROXY_PORT=8080

# iptables helper
fw() {
	sudo iptables $*
}

echo "[secfox] locking down system..."

# reset firewall
fw -F
fw -X

# allow SSH connections
fw -A INPUT -p tcp --dport 22 -j ACCEPT

# allow local connections
fw -A INPUT -s 127.0.0.1 -j ACCEPT

# allow open connections
fw -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
fw -A FORWARD -i eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
fw -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# only allow outgoing connection with our proxy
fw -A OUTPUT -p tcp -d $PROXY_IP --dport $PROXY_PORT -j ACCEPT

# reject everything else
fw -A INPUT -j REJECT
fw -A FORWARD -j REJECT
fw -A OUTPUT -j REJECT

echo "[secfox] system locked; only way out over $PROXY_IP:$PROXY_PORT"
