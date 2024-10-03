#!/bin/bash

set -eux

image="debian/12"

# Configuration
# =============
# Load secrets if available
if [ -f secrets.sh ]; then
	source secrets.sh	# **/secrets.sh ignored by git
fi

if [ -z ${RABBIT_USER} ]; then
	read -p "Enter new RabbitMQ user: " RABBIT_USER
fi
if [ -z ${RABBIT_PASSWD} ]; then
	read -p "Enter new RabbitMQ password: " RABBIT_PASSWD
fi
if [ -z ${OPENSEARCH_INITIAL_ADMIN_PASSWORD} ]; then
	read -p "Enter new opensearch admin password: " \
		OPENSEARCH_INITIAL_ADMIN_PASSWORD
fi


# OpenSearch SSL Certificate generation
# =====================================
# This is from https://opensearch.org/docs/latest/security/configuration/generate-certificates/
#
# Note CN for nodes and client - these have to match subjectAltName (SAN),
# although host name checking appears to be optional.
#
# For testing, with a self-signed root, we'll try & get away with as
# much as possible, but this is all worth a much closer look!
#
# To view a cert:
# openssl x509 -in node1.pem -text -noout

CFG_PATH=opensearch/config/single-node

# Root CA
openssl genrsa -out $CFG_PATH/root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key $CFG_PATH/root-ca-key.pem -subj "/C=UK/ST=ENGLAND/L=LONDON/O=IMPERIAL/OU=AERONAUTICS/CN=ROOT" -out $CFG_PATH/root-ca.pem -days 730

# Admin cert
openssl genrsa -out admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out $CFG_PATH/admin-key.pem
openssl req -new -key $CFG_PATH/admin-key.pem -subj "/C=UK/ST=ENGLAND/L=LONDON/O=IMPERIAL/OU=AERONAUTICS/CN=A" -out admin.csr
openssl x509 -req -in admin.csr -CA $CFG_PATH/root-ca.pem -CAkey $CFG_PATH/root-ca-key.pem -CAcreateserial -sha256 -out $CFG_PATH/admin.pem -days 730

# Node cert 1
openssl genrsa -out node1-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in node1-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out $CFG_PATH/node1-key.pem
openssl req -new -key $CFG_PATH/node1-key.pem -subj "/C=UK/ST=ENGLAND/L=LONDON/O=IMPERIAL/OU=AERONAUTICS/CN=node1.dns.a-record" -out node1.csr
echo 'subjectAltName=DNS:node1.dns.a-record' > node1.ext
openssl x509 -req -in node1.csr -CA $CFG_PATH/root-ca.pem -CAkey $CFG_PATH/root-ca-key.pem -CAcreateserial -sha256 -out $CFG_PATH/node1.pem -days 730 -extfile node1.ext

# Node cert 2
openssl genrsa -out node2-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in node2-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out $CFG_PATH/node2-key.pem
openssl req -new -key $CFG_PATH/node2-key.pem -subj "/C=UK/ST=ENGLAND/L=LONDON/O=IMPERIAL/OU=AERONAUTICS/CN=node2.dns.a-record" -out node2.csr
echo 'subjectAltName=DNS:node2.dns.a-record' > node2.ext
openssl x509 -req -in node2.csr -CA $CFG_PATH/root-ca.pem -CAkey $CFG_PATH/root-ca-key.pem -CAcreateserial -sha256 -out $CFG_PATH/node2.pem -days 730 -extfile node2.ext

# Client cert
openssl genrsa -out client-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in client-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out $CFG_PATH/client-key.pem
openssl req -new -key $CFG_PATH/client-key.pem -subj "/C=UK/ST=ENGLAND/L=LONDON/O=IMPERIAL/OU=AERONAUTICS/CN=client.dns.a-record" -out client.csr
echo 'subjectAltName=DNS:client.dns.a-record' > client.ext
openssl x509 -req -in client.csr -CA $CFG_PATH/root-ca.pem -CAkey $CFG_PATH/root-ca-key.pem -CAcreateserial -sha256 -out opensearch/client.pem -days 730 -extfile client.ext

# Cleanup
rm admin-key-temp.pem
rm admin.csr
rm node1-key-temp.pem
rm node1.csr
rm node1.ext
rm node2-key-temp.pem
rm node2.csr
rm node2.ext
rm client-key-temp.pem
rm client.csr
rm client.ext


### DEPLOY CONTAINERS ###

# RabbitMQ
incus launch images:$image rdm-rabbitmq
incus file push -r rabbitmq rdm-rabbitmq/root/
incus exec --cwd /root/rabbitmq rdm-rabbitmq -- ./build.sh ${RABBIT_USER} ${RABBIT_PASSWD}
echo "remove bind mount at /home/host"

# Postgresql
echo "Set lxc.signal.stop = SIGTERM"
echo "Mount data volume at /var/lib/postgres/data"
incus launch images:$image rdm-postgresql-1
incus file push -r postgresql rdm-postgresql-1/root/
incus exec --cwd /root/postgresql rdm-postgresql-1 -- ./build.sh
echo "remove bind mount at /home/host"

# Redis
incus launch images:$image rdm-redis
incus file push -r redis rdm-redis/root/
incus exec --cwd /root/redis rdm-redis -- ./build.sh
echo "remove bind mount at /home/host"

# OpenSearch
incus launch images:$image rdm-opensearch
incus file push -r opensearch rdm-opensearch/root/
incus exec --cwd /root/opensearch rdm-opensearch -- ./build.sh ${OPENSEARCH_INITIAL_ADMIN_PASSWORD}
echo "remove bind mount at /home/host"


