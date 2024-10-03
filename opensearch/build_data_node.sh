# Build follows the steps described here
# https://opensearch.org/docs/latest/install-and-configure/install-opensearch/debian/
# "Install OpenSeach from an APT repository"

# Mounts an external data volume into container (for a data node)

#############################################################################
#
# PRIOR TO RUNNING THIS SCRIPT 
#
# Calculate password hashes for admin and invenio_usr & copy these into internal_users.yml
#
#############################################################################
NAME=$1 #"opensearch_d1"
CONFIG_ROOT=$2 #"../lxc_config.conf"
DATA_MNT=$3 #"/home/leeb/.local/var/lxc/opensearch_1/data"
LOG_MNT=$4  #"/home/leeb/.local/var/lxc/opensearch_1/log"

export OPENSEARCH_VERSION='2.15.0'
export GPG_SIGNATURE='c5b7 4989 65ef d1c2 924b a9d5 39d3 1987 9310 d3fc'

echo $'\n'"lxc.mount.entry = ${PWD}/mount home/host none bind,create=dir 0 0"\
     $'\n'"lxc.mount.entry = ${DATA_MNT} var/opensearch/data none bind,create=dir 0 0"\
     $'\n'"lxc.mount.entry = ${DATA_MNT} var/opensearch/log none bind,create=dir 0 0"\
    | cat ${CONFIG_ROOT} -\
    | tee -a ${NAME}.conf

source ../create_container.sh
source ../secrets.sh

bash create_self_signed_ssl_certs.sh mount/certs

create_container ${NAME} ${NAME}.conf && \
    rm -f ${NAME}.conf && \ 


systemd-run --user --scope -p "Delegate=yes" -- lxc-start -n ${NAME} && \

systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n ${NAME} --clear-env \
	    --keep-var OPENSEARCH_INITIAL_ADMIN_PASSWORD \
	    --keep-var OPENSEARCH_VERSION \
	    --keep-var GPG_SIGNATURE \
	    -- /home/host/scripts/data-node/build.sh

systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n ${NAME} --clear-env \
	    -- /home/host/scripts/data-node/configure.sh


    
