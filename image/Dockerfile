# sarnowski/secfox-basic
#
FROM ubuntu:12.04
MAINTAINER "Tobias Sarnowski <tobias@sarnowski.io>"

# setup packages
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y openssh-server firefox

# sshd preparations
RUN mkdir -p /var/run/sshd
ADD sshd_config /etc/ssh/sshd_config

# populate files
RUN mkdir -p /secfox
ADD init.sh /secfox/init.sh
ADD firefox.sh /secfox/firefox.sh
RUN chown -R root:root /secfox
RUN chmod +x /secfox/*.sh

# setup user
RUN useradd -d /secfox/home -m secfox

# make SSH accessible
EXPOSE 22

# use initialization script
ENTRYPOINT ["/secfox/init.sh"]
