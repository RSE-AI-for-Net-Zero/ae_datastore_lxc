#!/bin/bash
set -x

export OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk

export PATH="/usr/share/opensearch/plugins/opensearch-security/tools/:${PATH}"

# run the enigmatic security admin script!
securityadmin.sh \
    -cd /etc/opensearch/opensearch-security/ \
    -cacert /etc/opensearch/root-ca.pem \
    -cert /etc/opensearch/admin.pem \
    -key /etc/opensearch/admin-key.pem -icl -nhnv

