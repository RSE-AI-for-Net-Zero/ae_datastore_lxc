NAME=$1 #"postgres_1"
DATA_MNT=$POSTGRESQL_DATA_MOUNT #"/home/leeb/.local/var/lxc/postgres/data"

MOUNT="${PREFIX}/services/postgresql"

if [ ! -f ${NAME}.conf ]
then
    echo $'\n'"lxc.mount.entry = ${MOUNT} root/host none bind,create=dir 0 0" \
	 $'\n'"lxc.mount.entry = ${DATA_MNT} var/lib/postgresql/data none bind,create=dir 0 0"\
	 $'\n'"lxc.signal.stop = SIGTERM"\
	| cat ${CONTAINER_CONFIG} -\
	| tee -a ${NAME}.conf
else
    echo "Config file already exists, moving on"
fi

create_container ${NAME} ${NAME}.conf

lxc_start -n ${NAME} && \

    lxc_attach -n ${NAME} --clear-env \
	       -- /root/host/scripts/build_node.sh && \

    lxc_attach -n ${NAME} --clear-env \
	       -- /root/host/scripts/add_trusted_host.sh ae-datastore-app && \

    lxc-stop -n ${NAME} && \
	
    sed -ir '/^lxc.mount.entry.*root\/host/d' ${LXC_UNPRIV_DIR}/${NAME}/config

    








