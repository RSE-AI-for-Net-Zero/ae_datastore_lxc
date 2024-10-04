#!/bin/bash
set -eux

export OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk

export PATH="/usr/share/opensearch/plugins/opensearch-security/tools/:${PATH}"

# delete the demo certs
rm -f /etc/opensearch/*.pem && \
    
# copy our versions of config files and certs into /etc
cp --recursive /home/host/config/data-node/* /etc/opensearch && \
    cp /home/host/certs/*.pem /etc/opensearch && \
    chmod o-r /etc/opensearch/*.pem

# Set the password hashes for admin and ae-datastore users
ADMIN_HASH=$(hash.sh -p ${OS_ADMIN_PASSWD})
AEDS_HASH=$(hash.sh -p ${OS_AEDATASTORE_PASSWD})
INTUSERS=/home/host/config/data-node/opensearch-security/internal_users.yml
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
    
chown --recursive opensearch:opensearch /etc/opensearch /var/opensearch/data \
	  /var/opensearch/log /var/log/opensearch

systemctl enable opensearch
systemctl restart opensearch

# run the enigmatic security admin script!
/usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh \
    -cd /etc/opensearch/opensearch-security/ \
    -cacert /etc/opensearch/root-ca.pem \
    -cert /etc/opensearch/admin.pem \
    -key /etc/opensearch/admin-key.pem -icl -nhnv
