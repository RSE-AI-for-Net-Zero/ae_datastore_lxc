set -eux

apt-get update && apt-get install -y redis-server

cp /root/redis/config/redis.conf /etc/redis
chown redis:redis /etc/redis/redis.conf

echo "vm.overcommit_memory = 1" | tee -a /etc/sysctl.conf

systemctl restart redis-server
