NAME=$1 #"postgres_1"
CONFIG_ROOT=$2 #"../lxc_config.conf"
DATA_MNT=$3 #"/home/leeb/.local/var/postgres/data"
#LOG_MNT=$4 #"/home/leeb/.local/var/log/postgres"

echo $'\n'"lxc.mount.entry = ${PWD}/mount home/host none bind,create=dir 0 0" \
     $'\n'"lxc.mount.entry = ${DATA_MNT} var/lib/postgres/data none bind,create=dir 0 0"\
     "lxc.signal.stop = SIGTERM"\
    | cat ${CONFIG_ROOT} -\
    | tee -a ${NAME}.conf

source ../create_container.sh 

create_container ${NAME} ${NAME}.conf && \
    rm -f ${NAME}.conf && \ 

systemd-run --user --scope -p "Delegate=yes" -- lxc-start -n ${FULL_NAME} && \

systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n ${FULL_NAME} --clear-env \
		-- /home/host/scripts/build_node.sh





