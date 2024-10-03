#!/bin/bash

set -eux

# copy our versions of config files and certs into /etc
cp --recursive /home/host/config/single-node/opensearch-security/* /etc/opensearch/opensearch-security/ && \
chown --recursive opensearch:opensearch /etc/opensearch /var/opensearch/data \
	  /var/opensearch/log

# run the enigmatic security admin script!
OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh -cd /etc/opensearch/opensearch-security/ -cacert /etc/opensearch/root-ca.pem -cert /etc/opensearch/admin.pem -key /etc/opensearch/admin-key.pem -icl -nhnv

systemctl restart opensearch
