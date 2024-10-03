#!/bin/bash

set -eux

# back-up the config files - could be useful in future
BACKUP_LOCATION=/home/backups
mkdir -p ${BACKUP_LOCATION}

cp --recursive /etc/opensearch ${BACKUP_LOCATION}

# delete demo ssl certs
rm /etc/opensearch/*.pem

# copy our versions of config files and certs into /etc
cp --recursive /home/host/config/single-node/* /etc/opensearch && \
cp /home/host/certs/* /etc/opensearch/ && \
chmod o-r /etc/opensearch/*key.pem && \
chown --recursive opensearch:opensearch /etc/opensearch /var/opensearch

systemctl restart opensearch && \

# run the enigmatic security admin script!
OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh -cd /etc/opensearch/opensearch-security/ -cacert /etc/opensearch/root-ca.pem -cert /etc/opensearch/admin.pem -key /etc/opensearch/admin-key.pem -icl -nhnv
