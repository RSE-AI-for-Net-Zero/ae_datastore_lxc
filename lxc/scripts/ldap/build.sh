NAME=$1 #"ldap"

MOUNT="${PREFIX}/services/ldap"

if [ ! -f ${NAME}.conf ]
then
    echo $'\n'"lxc.mount.entry = ${MOUNT} home/host none bind,create=dir 0 0" \
	| cat ${CONTAINER_CONFIG} -\
	| tee -a ${NAME}.conf
else
    echo "Config file already exists, moving on"
fi

create_container ${NAME} ${NAME}.conf && \

    lxc_start -n ${NAME} && \

    lxc_attach -n ${NAME} --clear-env \
	       -- /home/host/scripts/build.sh ${LDAP_PASSWD} && \

    lxc_attach -n ${NAME} --clear-env \
	       -- /home/host/scripts/configure.sh ${LDAP_PASSWD} && \
	
    lxc-stop -n ${NAME} && \

    sed -ir '/^lxc.mount.entry.*home\/host/d' ${LXC_UNPRIV_DIR}/${NAME}/config






