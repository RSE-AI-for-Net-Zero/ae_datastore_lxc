#!/bin/bash

set -eux

# move the files we're about the edit
mv /etc/opensearch/opensearch.yml /home/host/opensearch.yml.backup && \
mv /etc/opensearch/jvm.options /home/host/jvm.options.backup && \
mv /etc/opensearch/opensearch-security/internal_users.yml \
       /home/host/internal_users.backup && \

# delete the demo certs
rm -f /etc/opensearch/*.pem
    
# copy our versions of config files and certs into /etc

cp --recursive /home/host/config/single-node/* /etc/opensearch && \
chown --recursive opensearch:opensearch /etc/opensearch /var/opensearch/data \
      /var/opensearch/log

systemctl restart opensearch

export OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk

# run the enigmatic security admin script!
/usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh -cd /etc/opensearch/opensearch-security/ -cacert /etc/opensearch/root-ca.pem -cert /etc/opensearch/admin.pem -key /etc/opensearch/admin-key.pem -icl -nhnv
