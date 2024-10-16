NAME=$1 #ae-datastore
CONFIG_ROOT=$2 #../lxc_config.conf
DATA_MNT=$3 #/home/leeb/.local/var/lxc/ae-datastore/data
LOG_MNT=$4 #/home/leeb/.local/var/lxc/ae-datastore/log

source ../create_container.sh
source ../secrets.sh

NODE_SUFFIX= # Default is linux-x64.tar.xz, for something else, e.g. export NODE_SUFFIX='linux-arm64.tar.gz'

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

echo $'\n'"lxc.mount.entry = ${PWD}/mount home/host none bind,create=dir 0 0"\
     $'\n'"lxc.mount.entry = ${DATA_MNT} opt/invenio/var/instance/data none bind,create=dir 0 0"\
     $'\n'"lxc.mount.entry = ${LOG_MNT} opt/invenio/var/instance/log none bind,create=dir 0 0"\
    | cat ${CONFIG_ROOT} -\
    | tee -a ${NAME}.conf

create_container ${NAME} ${NAME}.conf && \
    rm -f ${NAME}.conf && \

systemd-run --user --scope -p "Delegate=yes" -- lxc-start -n ${NAME}    

systemd-run --user --scope -p "Delegate=yes" -- lxc-attach --clear-env -n ${NAME} \
	    --keep-var NODE_SUFFIX \
	    --keep-var RABBIT_PASSWD \
	    --keep-var OPENSEARCH_AEDATASTORE_PASSWD \
            -- /home/host/scripts/build_base.sh

systemd-run --user --scope -p "Delegate=yes" -- lxc-stop -n ${NAME}


