============================
Build the redis container
============================

Create an unpriviledged container, start it and attach terminal::

  (host)$ lxc-create -n redis -t download -- -d ubuntu -r focal -a amd64
  (host)$ lxc-unpriv-start -n redis
  (host)$ systemd-run --scope --user -p "Delegate=yes" -- lxc-attach -n redis


The following is run *inside* the container::

  (redis)$ sudo apt update && apt install -y lsb-release curl gpg openssh-server
  (redis)$ adduser --disabled-password --gecos "" user
  (redis)$ cd ~

Download and install redis::
  
  (redis)$ curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor \
     -o /usr/share/keyrings/redis-archive-keyring.gpg

  (redis)$ echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] \
     https://packages.redis.io/deb $(lsb_release -cs) main" \
     | sudo tee /etc/apt/sources.list.d/redis.list

  (redis)$ sudo apt update && apt -y install redis

Configure the container to bind to all interfaces and accept connections from remote hosts::

  (redis)$ sed -e /^bind/s/^/#/ -e /^protected-mode/s/yes/no/ /etc/redis/redis.conf | \
     tee redis.tmp.conf
     
  (redis)$ echo "bind 0.0.0.0" | tee -a redis.tmp.conf

Check that in ``redis.tmp.conf`` the line similar to ``bind 127.0.0.1`` is commented out and the line ``protected-mode yes`` has been replaced with ``protected-mode no``.  All good?::

  (redis)$ sudo mv redis.tmp.conf /etc/redis/redis.conf
  (redis)$ sudo systemctl restart redis-server

Ping the server from the host)::

  (host)$ telnet <redis-ip-address> 6379
  (telnet >) ping

The server should respond with ``PONG``.


  


  


  


