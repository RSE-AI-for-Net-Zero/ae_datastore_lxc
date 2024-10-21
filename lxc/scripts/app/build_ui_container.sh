APP_BASE_NAME=$1
FULL_NAME="${APP_BASE_NAME}-app"

lxc_copy -n ${APP_BASE_NAME} -N ${FULL_NAME} && \

    sed -ir '/^lxc.mount.entry.*home\/host/d' ${LXC_UNPRIV_DIR}/${FULL_NAME}/config && \

    echo "lxc.mount.entry = ${PREFIX}/services/app/ui home/host none bind,create=dir 0 0 " \
	| tee -a ${LXC_UNPRIV_DIR}/${FULL_NAME}/config && \

    lxc_start -n ${FULL_NAME} && \

    echo "waiting for IP addr"; sleep 1
    
    while ! container_has_ipv4 ${FULL_NAME} -i; do
	echo "waiting for IP addr"
	sleep 1
    done && \

    lxc_attach -n ${FULL_NAME} --clear-env \
	       -- /home/host/scripts/build_ui.sh ${RABBIT_PASSWD} \
	       ${OPENSEARCH_AEDATASTORE_PASSWD} && \

    lxc-stop -n ${FULL_NAME} && \

    sed -ir '/^lxc.mount.entry.*home\/host/d' ${LXC_UNPRIV_DIR}/${FULL_NAME}/config


