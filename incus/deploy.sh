#!/bin/bash

set -eux

image="debian/12"

PREFIX="/home/leeb/Projects/ae_datastore_lxc"
CMD=${INCUS_CMD:-"incus"} #in case we're doing "sudo incus"
NODE_SUFF=${NODE_SUFFIX:-"linux-x64.tar.xz"}

# Configuration
# =============
# Load secrets if available
if [ -f ${PREFIX}/scripts/secrets.sh ]; then
	source ${PREFIX}/scripts/secrets.sh	# **/secrets.sh ignored by git
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
if [ -z ${OPENSEARCH_ADMIN_PASSWD} ]; then
	read -p "Enter new opensearch admin password: " \
		OPENSEARCH_INITIAL_ADMIN_PASSWORD
fi
if [ -z ${OPENSEARCH_AEDATASTORE_PASSWD} ]; then
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

SSL_PATH=${PREFIX}/ssl
mkdir -p ${SSL_PATH}/certs ${SSL_PATH}/keys

bash ${PREFIX}/scripts/create_self_signed_ssl_certs.sh  ${SSL_PATH}
### DEPLOY CONTAINERS ###

# OpenSearch
echo """
Bind mounts: 
Data -> /var/opensearch/data
Logs -> /var/log/opensearch
"""
OPENSEARCH_VERSION='2.15.0'
GPG_SIGNATURE='c5b7 4989 65ef d1c2 924b a9d5 39d3 1987 9310 d3fc'

cp -R ${SSL_PATH} ${PREFIX}/services/opensearch/data-node
${CMD} launch images:$image rdm-opensearch-d1
${CMD} file create -p rdm-opensearch-d1/home/host/
${CMD} file create -p rdm-opensearch-d1/var/opensearch/data/
${CMD} file create -p rdm-opensearch-d1/var/log/opensearch/
${CMD} config device add rdm-opensearch-d1 external-data disk \
      source=/home/leeb/.local/var/lxc/opensearch_d1/data path=/var/opensearch/data
${CMD} config device add rdm-opensearch-d1 external-log disk \
      source=/home/leeb/.local/var/lxc/opensearch_d1/log path=/var/log/opensearch
${CMD} file push -r ${PREFIX}/services/opensearch/data-node/* rdm-opensearch-d1/home/host
${CMD} exec --cwd / rdm-opensearch-d1 \
      -- /home/host/scripts/build.sh ${OPENSEARCH_INITIAL_ADMIN_PASSWORD} \
      ${OPENSEARCH_VERSION} \
      ${GPG_SIGNATURE}
${CMD} exec --cwd / rdm-opensearch-d1 \
      -- /home/host/scripts/configure.sh ${OPENSEARCH_ADMIN_PASSWD} \
      ${OPENSEARCH_AEDATASTORE_PASSWD}
${CMD} file delete -f rdm-opensearch-d1/home/host/
# A quick test that admin & user passwords set ok and that ae-datastore
#  can create and destroy an index
#
# #Get cluster info:
# curl -k -X GET -u 'admin:<admin-psswd>' https://rdm-opensearch-d1:9200
#
# #Create an index called 'doggos' then delete it
# curl -k -X PUT -u 'ae-datastore:<ae-ds-psswd>' https://rdm-opensearch-d1:9200/doggos
# curl -k -X DELETE -u 'ae-datastore:<ae-ds-psswd>' https://rdm-opensearch-d1:9200/doggos

# RabbitMQ
${CMD} launch images:$image rdm-rabbitmq
${CMD} file create -p rdm-rabbitmq/home/host/
${CMD} file push -r ${PREFIX}/services/rabbitmq/* rdm-rabbitmq/home/host
${CMD} exec --cwd / rdm-rabbitmq -- /home/host/scripts/build.sh ${RABBIT_PASSWD}
${CMD} file delete -f rdm-rabbitmq/home/host/

# Postgresql
# It says here https://linuxcontainers.org/incus/docs/main/api-extensions/
#  that SIGTERM is "forwarded", whatever this means
# Tried sudo kill -s SIGTERM <rdm-postgresql-1 PID> but it carries on regardless
# 
# Postgresql has three modes of shutdown - the most graceful is on receiving SIGTERM
# All pending transactions are completed (and no new ones accepted) before shutdown.
#
# For bare LXC, we just add lxc.signal.stop = SIGTERM to the container's config
# 
${CMD} launch images:$image rdm-postgresql-1
${CMD} file create -p rdm-postgresql-1/home/host/
${CMD} file create -p rdm-postgresql-1/var/lib/postgres/data/
${CMD} config device add rdm-postgresql-1 external-data disk \
      source=/home/leeb/.local/var/lxc/postgresql_1/data path=/var/lib/postgresql/data
${CMD} file push -r ${PREFIX}/services/postgresql/* rdm-postgresql-1/home/host
${CMD} exec --cwd / rdm-postgresql-1 -- /home/host/scripts/build_node.sh
${CMD} exec --cwd / rdm-postgresql-1 -- cp /home/host/scripts/add_trusted_host.sh /usr/local/bin
${CMD} exec --cwd / rdm-postgresql-1 -- add_trusted_host.sh rdm-invenio-ui
${CMD} exec --cwd / rdm-postgresql-1 -- add_trusted_host.sh rdm-invenio-api
${CMD} file delete -f rdm-postgresql-1/home/host/

# Redis
${CMD} launch images:$image rdm-redis
${CMD} file create -p rdm-redis/home/host/
${CMD} file push -r ${PREFIX}/services/redis/* rdm-redis/home/host
${CMD} exec --cwd / rdm-redis -- /home/host/scripts/build.sh
${CMD} file delete -f rdm-redis/home/host/

# invenio-base
${CMD} launch images:$image rdm-base
${CMD} file create -p rdm-base/home/host/
${CMD} file create -p rdm-base/opt/invenio/var/instance/data/
${CMD} file create -p rdm-base/opt/invenio/var/instance/log/
${CMD} config device add rdm-base external-data disk \
       source=/home/leeb/.local/var/lxc/ae-datastore/data path=/opt/invenio/var/instance/data
${CMD} config device add rdm-base external-log disk \
       source=/home/leeb/.local/var/lxc/ae-datastore/log path=/opt/invenio/var/instance/log
${CMD} file push -r ${PREFIX}/services/app/base/* rdm-base/home/host
${CMD} exec --cwd / rdm-base -- /home/host/scripts/build_base.sh ${NODE_SUFF}
${CMD} file delete -f rdm-base/home/host/
${CMD} stop rdm-base

# invenio-ui
${CMD} copy rdm-base rdm-invenio-ui



