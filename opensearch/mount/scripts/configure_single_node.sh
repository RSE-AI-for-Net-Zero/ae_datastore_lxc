#!/bin/bash

set -eux

# delete the demo certs
rm -f /etc/opensearch/*.pem && \
    
# copy our versions of config files and certs into /etc
cp --recursive /home/host/config/single-node/* /etc/opensearch && \
    cp /home/host/certs/*.pem /etc/opensearch && \
    chmod o-r /etc/opensearch/*.pem
    
chown --recursive opensearch:opensearch /etc/opensearch /var/opensearch/data \
	  /var/opensearch/log

systemctl enable opensearch
systemctl restart opensearch

# run the enigmatic security admin script!
OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh -cd /etc/opensearch/opensearch-security/ -cacert /etc/opensearch/root-ca.pem -cert /etc/opensearch/admin.pem -key /etc/opensearch/admin-key.pem -icl -nhnv
