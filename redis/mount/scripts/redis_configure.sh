#!/bin/bash

set -eux

cp /home/host/config/redis.conf /etc/redis
chown redis:redis /etc/redis/redis.conf

echo "vm.overcommit_memory = 1" | tee -a /etc/sysctl.conf

systemctl restart redis-server
