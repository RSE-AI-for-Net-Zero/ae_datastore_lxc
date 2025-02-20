BASE_NAME=$1
NAME=$2

lxc_copy -n ${BASE_NAME} -N ${NAME} && \

    sed -ir '/^lxc.mount.entry.*root\/host/d' ${LXC_UNPRIV_DIR}/${NAME}/config && \

    echo "lxc.mount.entry = ${PREFIX}/services/app/app root/host none bind,create=dir 0 0 " \
	| tee -a ${LXC_UNPRIV_DIR}/${NAME}/config && \

    lxc_start -n ${NAME} && \

    echo "waiting for IP addr"; sleep 1
    
    while ! container_has_ipv4 ${NAME} -i; do
	echo "waiting for IP addr"
	sleep 1
    done && \

    lxc_attach -n ${NAME} --clear-env \
	       -- /root/host/scripts/build.sh ${RABBIT_PASSWD} \
	       ${OPENSEARCH_AEDATASTORE_PASSWD} && \

    lxc-stop -n ${NAME} && \

    sed -ir '/^lxc.mount.entry.*root\/host/d' ${LXC_UNPRIV_DIR}/${NAME}/config


