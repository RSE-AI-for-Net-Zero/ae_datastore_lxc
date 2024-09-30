CONFIG_ROOT=$1 #"../lxc_config.conf"

NAME='python39'
echo $'\n'"lxc.mount.entry = ${PWD}/mount home/host none bind,create=dir 0 0"\
    | cat ${CONFIG_ROOT} -\
    | tee -a ${NAME}.conf

source ../create_container.sh

create_container ${NAME} ${NAME}.conf && \
    rm -f ${NAME}.conf && \ 

systemd-run --user --scope -p "Delegate=yes" -- lxc-start -n ${FULL_NAME}

systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n ${FULL_NAME} --clear-env \
	    -- /home/host/scripts/build_python39.sh

systemd-run --user --scope -p "Delegate=yes" -- lxc-stop -n ${FULL_NAME}














    
