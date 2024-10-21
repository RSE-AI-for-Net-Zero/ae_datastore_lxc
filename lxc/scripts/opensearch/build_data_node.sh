# Build follows the steps described here
# https://opensearch.org/docs/latest/install-and-configure/install-opensearch/debian/
# "Install OpenSeach from an APT repository"

# Mounts an external data volume into container (for a data node)
NAME=$1 #"opensearch_d1"
DATA_MNT=$2 #"/home/leeb/.local/var/lxc/opensearch_1/data"
LOG_MNT=$3 #"/home/leeb/.local/var/lxc/opensearch_1/log"

OPENSEARCH_VERSION='2.15.0'
GPG_SIGNATURE='c5b7 4989 65ef d1c2 924b a9d5 39d3 1987 9310 d3fc'

MOUNT="${PREFIX}/services/opensearch/data-node"

if [ ! -f ${NAME}.conf ]
then
echo $'\n'"lxc.mount.entry = ${MOUNT} home/host none bind,create=dir 0 0"\
     $'\n'"lxc.mount.entry = ${DATA_MNT} var/opensearch/data none bind,create=dir 0 0"\
     $'\n'"lxc.mount.entry = ${LOG_MNT} var/log/opensearch none bind,create=dir 0 0"\
    | cat ${CONTAINER_CONFIG} -\
    | tee -a ${NAME}.conf
else
    echo "Config file already exists, moving on"
fi


create_container ${NAME} ${NAME}.conf && \
    
    lxc_start -n ${NAME} && \

    cp -R ssl/ ${MOUNT} && \
    
    lxc_attach -n ${NAME} --clear-env -- \
	       /home/host/scripts/build.sh ${OPENSEARCH_INITIAL_ADMIN_PASSWORD} \
	       ${OPENSEARCH_VERSION} ${GPG_SIGNATURE} && \

    lxc_attach -n ${NAME} --clear-env -- \
	       /home/host/scripts/configure.sh ${OPENSEARCH_ADMIN_PASSWD} \
	       ${OPENSEARCH_AEDATASTORE_PASSWD} && \

    lxc-stop -n ${NAME} && \

    sed -ir '/^lxc.mount.entry.*home\/host/d' ${LXC_UNPRIV_DIR}/${NAME}/config







    
