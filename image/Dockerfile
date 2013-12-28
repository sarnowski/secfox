# sarnowski/secfox-basic
#
FROM ubuntu:12.04
MAINTAINER "Tobias Sarnowski <tobias@sarnowski.io>"

# setup packages
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y openssh-server firefox sudo iptables

# sshd preparations
RUN mkdir -p /var/run/sshd
ADD sshd_config /etc/ssh/sshd_config

# sudo preparations
RUN echo "secfox ALL=NOPASSWD: ALL" >> /etc/sudoers

# populate files
RUN mkdir -p /secfox
ADD init.sh /secfox/init.sh
ADD firefox.sh /secfox/firefox.sh
RUN chown -R root:root /secfox
RUN chmod +x /secfox/*.sh

# setup user
RUN useradd -d /secfox/home -m secfox

# setup firefox
RUN mkdir -p /secfox/home/.mozilla/firefox/secfox
ADD profiles.ini /secfox/home/.mozilla/firefox/profiles.ini

RUN mkdir -p /secfox/home/Downloads

# fix permissions
RUN chown -R secfox /secfox/home

# make SSH accessible
EXPOSE 22

# use initialization script
ENTRYPOINT ["/secfox/init.sh"]
