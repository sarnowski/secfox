# secfox / secure firefox


## Features

* firefox has no access to your system
* malicious websites cannot compromise your computer
* a fresh system on every start
* separated from your "normal" firefox


## Use case

Using I2P or Tor is not easy to set up right. Little mistakes can reveal your
identity. This is especially hard if you try to set up everything in one
browser. This application should make it easy to run a vanilla browser for
your anonymous activities.


## WARNING

This is only one part in securing your computer and hiding your identity. If
you really care about anonymity and security, get firm with the topics first!


## Prerequisites

* http://www.docker.io/gettingstarted/#h_installation

Note: I only tested this with Ubuntu Linux. If you're using Mac OS X or Windows
use VirtualBox to run Ubuntu Linux.


## Get started

Clone this git repository to your local machine. Afterwards, go into the
directory and issue the following command:

  ./secfox.sh

The first time, this could take some time. Further calls will only take milli-
seconds.


## Configuration

After the first start, you have a `config` directory. Its content will be used
to set up your firefox profile. By default, it has a minimal setup.

### Examples

There are some examples provided in the `examples` directory. You can e.g. add
some privacy options to your secfox by adding the content of the
`user.privacy.js` file to your `config/user.js` file:

  cat examples/user.privacy.js >> config/user.js

### Recommended I2P setup

In order to use secfox with I2P it is recommended to do the following steps:

  cat examples/user.defaults.js \
      examples/user.privacy.js \
      examples/user.proxy.js \
      > config/user.js

Then open your `config/user.js` and change the following settings:

* network.proxy.http = [your I2P router IP]
* network.proxy.http_port = [your I2P router port, usually 4444]
* browser.search.defaultenginename = "I2P Forum"

E.g. if you are using a Raspberry PI for your I2P router with the imaginary
IP `192.168.1.100`, the lines should look like:

  user_pref("network.proxy.http", "192.168.1.100");
  user_pref("network.proxy.http_port", 4444);
  user_pref("browser.search.defaultenginename", "I2P Forum");
