set -eux

apt-get update && \
apt-get install -y --no-install-recommends lsb-release curl gpg ca-certificates && \
    
curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg && \

echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" > /etc/apt/sources.list.d/redis.list && \

apt-get update && apt-get install -y redis-server && \

cp config/redis.conf /etc/redis && \
chown redis:redis /etc/redis/redis.conf && \

#echo "vm.overcommit_memory = 1" | tee -a /etc/sysctl.conf

systemctl restart redis-server
