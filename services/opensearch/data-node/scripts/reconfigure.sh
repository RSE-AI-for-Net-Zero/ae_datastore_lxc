#!/bin/bash

set -eux

# copy our versions of config files and certs into /etc
cp --recursive /root/host/config/data-node/opensearch-security/* /etc/opensearch/opensearch-security/ && \
chown --recursive opensearch:opensearch /etc/opensearch /var/opensearch/data \
	  /var/opensearch/log

# run the enigmatic security admin script!
OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh -cd /etc/opensearch/opensearch-security/ -cacert /etc/opensearch/certs/root-ca.pem -cert /etc/opensearch/certs/admin.pem -key /etc/opensearch/keys/admin-key.pem -icl -nhnv

systemctl restart opensearch
