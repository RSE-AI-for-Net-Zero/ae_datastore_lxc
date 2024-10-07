NAME=$1 #"postgres_1"
CONFIG_ROOT=$2 #"../lxc_config.conf"
DATA_MNT=$3 #"/home/leeb/.local/var/lxc/postgres/data"

echo $'\n'"lxc.mount.entry = ${PWD}/mount home/host none bind,create=dir 0 0" \
     $'\n'"lxc.mount.entry = ${DATA_MNT} var/lib/postgres/data none bind,create=dir 0 0"\
     "lxc.signal.stop = SIGTERM"\
    | cat ${CONFIG_ROOT} -\
    | tee -a ${NAME}.conf

source ../create_container.sh 

create_container ${NAME} ${NAME}.conf && \
    rm -f ${NAME}.conf && \ 

systemd-run --user --scope -p "Delegate=yes" -- lxc-start -n ${NAME} && \

systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n ${NAME} --clear-env \
	    -- /home/host/scripts/build_node.sh

systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n ${NAME} --clear-env \
	    -- /home/host/scripts/add_trusted_host.sh "aedataui"

systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n ${NAME} --clear-env \
	    -- /home/host/scripts/add_trusted_host.sh "aedataapi" 







