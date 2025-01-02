NAME=$1 #"rabbitmq"

MOUNT="${PREFIX}/services/rabbitmq"

if [ ! -f ${NAME}.conf ]
then
    echo $'\n'"lxc.mount.entry = ${MOUNT} root/host none bind,create=dir 0 0"\
	| cat ${CONTAINER_CONFIG} -\
	| tee -a ${NAME}.conf
else
    echo "Config file already exists, moving on"
fi


create_container ${NAME} ${NAME}.conf
    
lxc_start -n ${NAME} && \
    
    lxc_attach -n ${NAME} --clear-env \
	       -- /root/host/scripts/build.sh ${RABBIT_PASSWD} && \

    lxc-stop -n ${NAME} && \
	
    sed -ir '/^lxc.mount.entry.*root\/host/d' ${LXC_UNPRIV_DIR}/${NAME}/config
    




