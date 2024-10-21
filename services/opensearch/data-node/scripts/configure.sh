#!/bin/bash
set -eux

OPENSEARCH_ADMIN_PASSWD=$1
OPENSEARCH_AEDATASTORE_PASSWD=$2

export OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk
export PATH="/usr/share/opensearch/plugins/opensearch-security/tools/:${PATH}"

# delete the demo certs
rm -f /etc/opensearch/*.pem && \
    
# copy our versions of config files and certs into /etc
# See: https://opensearch.org/docs/latest/security/configuration/index/
cp -R /home/host/config/* /etc/opensearch && \
    cp -R /home/host/ssl/* /etc/opensearch && \
    chown -R opensearch:opensearch /etc/opensearch && \
    chmod 644 /etc/opensearch/certs/* && \
    chmod 600 /etc/opensearch/keys/*


# Set the password hashes for admin and ae-datastore users
ADMIN_HASH=$(hash.sh -p ${OPENSEARCH_ADMIN_PASSWD})
AEDS_HASH=$(hash.sh -p ${OPENSEARCH_AEDATASTORE_PASSWD})
INTUSERS=/etc/opensearch/opensearch-security/internal_users.yml
TMPUSERS=/tmp/internal_users.yml
# See https://stackoverflow.com/questions/407523/escape-a-string-for-a-sed-replace-pattern
#  for how to deal with replacement strings containing characters sed considers special in
#  this context.  Here opted for the simplest solution replacing s/// with s~~~
#
# Whether this will always work depends on the encoding the hash.sh script uses but this isn't
#  clearly documented, as far as a quick search reveals

cp ${INTUSERS} ${TMPUSERS}

sed -ri "/^admin\:\s*$/, /^\s*$/ s~(^\s*hash)\:\s*\S+\s*~\1: \"${ADMIN_HASH}\"~" ${TMPUSERS}
sed -ri "/^ae-datastore\:\s*$/, /^\s*$/ s~(^\s*hash)\:\s*\S+\s*~\1: \"${AEDS_HASH}\"~" ${TMPUSERS}

# It would be nice to do a quick grep on ${TMPUSERS} to check that the hashed password did indeed end
#  up in the .yml file, but that's another can of worms...

cp ${TMPUSERS} /etc/opensearch/opensearch-security/internal_users.yml
    
chown --recursive opensearch:opensearch /var/opensearch \
	  /var/log/opensearch

systemctl daemon-reload
systemctl enable opensearch.service
systemctl start opensearch.service

sleep 20

# run the enigmatic security admin script!
securityadmin.sh \
    -cd /etc/opensearch/opensearch-security/ \
    -cacert /etc/opensearch/certs/root-ca.pem \
    -cert /etc/opensearch/certs/admin.pem \
    -key /etc/opensearch/keys/admin-key.pem -icl -nhnv


