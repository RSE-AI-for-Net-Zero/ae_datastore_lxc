NAME=$1 #ae-datastore
DATA_MNT=$2 #/home/leeb/.local/var/lxc/ae-datastore/data
LOG_MNT=$3 #/home/leeb/.local/var/lxc/ae-datastore/log

########################################################################################
# Set permission for local file storage directory
#
# group lxc has gid 100 000, which is set to map to 0 (root) in container
#
# mkdir -p ~/.local/var/lxc/ae-datastore/data
# chgrp lxc ~/.local/var/lxc/ae-datastore ~/.local/var/lxc/ae-datastore/data
# chmod g+w ~/.local/var/lxc/ae-datastore/data
# chmod o-rx ~/.local/var/lxc/ae-datastore/data
#
# When build is finished and invenio user created in container, change permissions again
#
# ---------- To do ----------
# set lxc.signal.stop
#
########################################################################################

MOUNT="${PREFIX}/services/app/base"

if [ ! -f ${NAME}.conf ]
then
    echo $'\n'"lxc.mount.entry = ${MOUNT} home/host none bind,create=dir 0 0"\
	 $'\n'"lxc.mount.entry = ${DATA_MNT} opt/invenio/var/instance/data none bind,create=dir 0 0"\
	 $'\n'"lxc.mount.entry = ${LOG_MNT} opt/invenio/var/instance/log none bind,create=dir 0 0"\
        | cat ${CONTAINER_CONFIG} -\
	| tee -a ${NAME}.conf
else
    echo "Config file already exists, moving on"
fi


create_container ${NAME} ${NAME}.conf && \
    
    lxc_start -n ${NAME} && \

    lxc_attach --clear-env -n ${NAME} \
            -- /home/host/scripts/build_base.sh ${NODE_SUFFIX} && \

    lxc-stop -n ${NAME} && \

    sed -ir '/^lxc.mount.entry.*home\/host/d' ${LXC_UNPRIV_DIR}/${NAME}/config



