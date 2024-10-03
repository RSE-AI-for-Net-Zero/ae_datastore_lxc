set -eux

apt-get update && apt-get -y install lsb-release ca-certificates curl gnupg2 grep

curl -o /tmp/opensearch-2.17.1-linux-x64.tar.gz https://artifacts.opensearch.org/releases/bundle/opensearch/2.17.1/opensearch-2.17.1-linux-x64.tar.gz
curl -o /tmp/opensearch-2.17.1-linux-x64.tar.gz.sig https://artifacts.opensearch.org/releases/bundle/opensearch/2.17.1/opensearch-2.17.1-linux-x64.tar.gz.sig
curl -o- https://artifacts.opensearch.org/publickeys/opensearch.pgp | gpg --import -
gpg --verify /tmp/opensearch-2.17.1-linux-x64.tar.gz.sig /tmp/opensearch-2.17.1-linux-x64.tar.gz

#curl -o- https://artifacts.opensearch.org/publickeys/opensearch.pgp | gpg --dearmor --batch --yes -o /usr/share/keyrings/opensearch-keyring

#echo "deb [signed-by=/usr/share/keyrings/opensearch-keyring] https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/apt stable main" | tee /etc/apt/sources.list.d/opensearch-2.x.list

#apt-get update
#apt-get install opensearch=2.17.1

#if [ -n $'gpg --no-default-keyring --keyring /usr/share/keyrings/opensearch-keyring \
#       --fingerprint | grep --ignore-case ${GPG_SIGNATURE}' ]
#then
#    echo "GPG key: ${GPG_SIGNATURE} - verified"
#fi

#systemctl enable opensearch
#systemctl start opensearch

#BACKUP_LOCATION=/home/backups
#mkdir -p ${BACKUP_LOCATION}

#cp --recursive /etc/opensearch ${BACKUP_LOCATION}

# delete demo ssl certs
#rm /etc/opensearch/*.pem

# copy our versions of config files and certs into /etc
#cp --recursive /home/host/config/single-node/* /etc/opensearch && \
#cp /home/host/certs/* /etc/opensearch/ && \
#chmod o-r /etc/opensearch/*key.pem && \
#chown --recursive opensearch:opensearch /etc/opensearch /var/opensearch

#systemctl restart opensearch

# run the enigmatic security admin script!
#export OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk

#/usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh \
#    -cd /etc/opensearch/opensearch-security/ \
#    -cacert /etc/opensearch/root-ca.pem \
#    -cert /etc/opensearch/admin.pem \
#    -key /etc/opensearch/admin-key.pem -icl -nhnv

    
#apt-get update && \
#    apt-get -y install lsb-release ca-certificates curl gnupg2 grep && \

#curl -o- https://artifacts.opensearch.org/publickeys/opensearch.pgp |\
#    gpg --dearmor --batch --yes -o /usr/share/keyrings/opensearch-keyring && \

#echo """
#deb [signed-by=/usr/share/keyrings/opensearch-keyring] https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/apt stable main""" \
#    | tee /etc/apt/sources.list.d/opensearch-2.x.list && \
 #   apt-get update && \
    # OPENSEARCH_INITIAL_ADMIN_PASSWORD should be set in host environment
    #  and propagated to here (lxc-attach propagates environ. by default)
  #  apt-get install opensearch=${OPENSEARCH_VERSION} && \
   # [ -n `gpg --no-default-keyring --keyring /usr/share/keyrings/opensearch-keyring \
    # --fingerprint |\ grep --ignore-case ${GPG_SIGNATURE}` ] && \

    #echo "GPG key: ${GPG_SIGNATURE} - verified"

# back-up the config files - could be useful in future
#BACKUP_LOCATION=/home/backups
#mkdir -p ${BACKUP_LOCATION}

#cp --recursive /etc/opensearch ${BACKUP_LOCATION}

# delete demo ssl certs
#rm /etc/opensearch/*.pem

# copy our versions of config files and certs into /etc
#cp --recursive /home/host/config/single-node/* /etc/opensearch && \
#cp /home/host/certs/* /etc/opensearch/ && \
#chmod o-r /etc/opensearch/*key.pem && \
#chown --recursive opensearch:opensearch /etc/opensearch /var/opensearch

#systemctl restart opensearch && \

# run the enigmatic security admin script!
#OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh -cd /etc/opensearch/opensearch-security/ -cacert /etc/opensearch/root-ca.pem -cert /etc/opensearch/admin.pem -key /etc/opensearch/admin-key.pem -icl -nhnv


    
   

	


