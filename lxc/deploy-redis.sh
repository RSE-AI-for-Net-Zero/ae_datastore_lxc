NAME=$1 #"redis"

MOUNT="${PREFIX}/services/redis"

if [ ! -f ${NAME}.conf ]
then
    echo $'\n'"lxc.mount.entry = ${MOUNT} root/host none bind,create=dir 0 0" \
	| cat ${CONTAINER_CONFIG} -\
	| tee -a ${NAME}.conf
else
    echo "Config file already exists, moving on"
fi

create_container ${NAME} ${NAME}.conf

lxc_start -n ${NAME} && \
    
    lxc_attach -n ${NAME} --clear-env \
	       -- /root/host/scripts/build.sh && \

    lxc_attach -n ${NAME} --clear-env \
	       -- /root/host/scripts/configure.sh && \

    lxc-stop -n ${NAME} && \
	
    sed -ir '/^lxc.mount.entry.*root\/host/d' ${LXC_UNPRIV_DIR}/${NAME}/config

    
    





