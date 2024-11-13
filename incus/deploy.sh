#!/bin/bash

set -eux

image="debian/12"

PREFIX="/home/leeb/Projects/ae_datastore_lxc"
CMD=${INCUS_CMD:-incus} #in case we're doing "sudo incus"

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

${CMD} launch images:$image rdm-opensearch-d1
cp -R ${SSL_PATH} ${PREFIX}/services/opensearch/data-node
${CMD} file create -p rdm-opensearch-d1/home/host/
${CMD} file create -p rdm-opensearch-d1/var/opensearch/data/
${CMD} file create -p rdm-opensearch-d1/var/log/opensearch/
${CMD} config device add rdm-opensearch-d1 external-data disk \
      source=/home/leeb/.local/var/lxc/opensearch_d1/data path=/var/opensearch/data
${CMD} config device add rdm-opensearch-d1 external-log disk \
      source=/home/leeb/.local/var/lxc/opensearch_d1/log path=/var/log/opensearch
${CMD} file push -r ${PREFIX}/services/opensearch/data-node rdm-opensearch-d1/home/host
${CMD} exec --cwd / rdm-opensearch-d1 \
      -- /home/host/data-node/scripts/build.sh ${OPENSEARCH_INITIAL_ADMIN_PASSWORD} \
      ${OPENSEARCH_VERSION} \
      ${GPG_SIGNATURE}
${CMD} exec --cwd / rdm-opensearch-d1 \
      -- /home/host/data-node/scripts/configure.sh ${OPENSEARCH_ADMIN_PASSWD} \
      ${OPENSEARCH_AEDATASTORE_PASSWD}
# We now should remove the build scripts and config from the container
#  in LXC terms you would remove the bind mount at /home/host by deleting
#  the relevant lxc.mount.entry from the container's config file.
#

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
incus launch images:$image rdm-rabbitmq
incus file push -r ${PREFIX}/services/rabbitmq rdm-rabbitmq/root/
incus exec --cwd /root/rabbitmq rdm-rabbitmq -- ./build.sh ${RABBIT_PASSWD}
incus file pull -r rdm-rabbitmq/root/rabbitmq /tmp

# Postgresql
echo "Set lxc.signal.stop = SIGTERM"
echo "Bind mount data volume at /var/lib/postgres/data"
incus launch images:$image rdm-postgresql-1
incus file push -r postgresql rdm-postgresql-1/root/
incus exec --cwd /root/postgresql/scripts rdm-postgresql-1 -- ./build_node.sh
incus exec --cwd /root/postgresql/scripts rdm-postgresql-1 -- ./add_trusted_host.sh rdm-uwsgi-ui
incus exec --cwd /root/postgresql/scripts rdm-postgresql-1 -- ./add_trusted_host.sh rdm-uwsgi-api
incus file pull -r rdm-postgresql-d1/root/postgresql /tmp

# Redis
incus launch images:$image rdm-redis
incus file push -r redis rdm-redis/root/
incus exec --cwd /root/redis rdm-redis -- ./build.sh
incus file pull -r rdm-redis/root/redis /tmp



