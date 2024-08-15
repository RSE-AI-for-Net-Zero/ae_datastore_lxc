NAME=$1 #"redis"
CONFIG_ROOT=$2 #"../lxc_config.conf"

echo $'\n'"lxc.mount.entry = ${PWD}/mount home/host none bind,create=dir 0 0" \
    | cat ${CONFIG_ROOT} -\
    | tee -a ${NAME}.conf

source ../create_container.sh 

create_container ${NAME} ${NAME}.conf && \
    #lxc will store the container config somewhere
    rm -f ${NAME}.conf && \ 
    systemd-run --user --scope -p "Delegate=yes" -- lxc-start -n ${FULL_NAME} && \
    systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n ${FULL_NAME} --clear-env \
		-- /home/host/scripts/redis_build.sh
    systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n ${FULL_NAME} --clear-env \
		-- /home/host/scripts/redis_configure.sh
    





