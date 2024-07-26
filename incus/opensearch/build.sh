set -eux

export OPENSEARCH_VERSION="2.15.0"

export OPENSEARCH_INITIAL_ADMIN_PASSWORD="$1"
export GPG_SIGNATURE="c5b7 4989 65ef d1c2 924b a9d5 39d3 1987 9310 d3fc"

apt-get update && \
apt-get -y install lsb-release ca-certificates curl gnupg2 grep && \

curl -o- https://artifacts.opensearch.org/publickeys/opensearch.pgp |\
    gpg --dearmor --batch --yes -o /usr/share/keyrings/opensearch-keyring && \

echo "${OPENSEARCH_INITIAL_ADMIN_PASSWORD}"

echo "
deb [signed-by=/usr/share/keyrings/opensearch-keyring] https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/apt stable main" > /etc/apt/sources.list.d/opensearch-2.x.list && \
    apt-get update && \
    # OPENSEARCH_INITIAL_ADMIN_PASSWORD should be set in host environment
    #  and propagated to here (lxc-attach propagates environ. by default)
    apt-get install opensearch=${OPENSEARCH_VERSION} && \
    [ -n `gpg --no-default-keyring --keyring /usr/share/keyrings/opensearch-keyring \
     --fingerprint | grep --ignore-case "${GPG_SIGNATURE}"` ] && \

    echo "GPG key: ${GPG_SIGNATURE} - verified"

# move the files we're about the edit
mv /etc/opensearch/opensearch.yml /home/opensearch.yml.backup && \
mv /etc/opensearch/jvm.options /home/jvm.options.backup && \
mv /etc/opensearch/opensearch-security/internal_users.yml /home/internal_users.backup && \

# delete the demo certs
rm -f /etc/opensearch/*.pem && \
    
# copy our versions of config files and certs into /etc
cp --recursive config/single-node/* /etc/opensearch && \
#mkdir -p /var/log/opensearch /var/lib/opensearch
chown --recursive opensearch:opensearch /etc/opensearch /var/lib/opensearch /var/log/opensearch

# Restart opensearch and enable on boot
systemctl daemon-reload
systemctl enable opensearch
systemctl restart opensearch

# run the enigmatic security admin script!
OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh -cd /etc/opensearch/opensearch-security/ -cacert /etc/opensearch/root-ca.pem -cert /etc/opensearch/admin.pem -key /etc/opensearch/admin-key.pem -icl -nhnv


