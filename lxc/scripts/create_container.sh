set -u # Fail on unset variables

am_i_root ()
{
    if [ `id -u` -eq 0 ]; then
	echo "You might be root. Exiting.";
	exit 1;
    fi
}

create_container ()
{
    #create_container CONTAINER_NAME
    am_i_root
    FULL_NAME=$1
    #"_"${DISTR}"_"${RELEA}"_"${ARCHE}
    CONFIG=$2
    lxc-create -n $FULL_NAME -t download -f ${CONFIG} -- \
               -d ${LXC_DIST} -r ${LXC_REL} -a ${LXC_ARCH}
}

container_has_ipv4 ()
{
    IP="$(systemd-run --user --scope -p "Delegate=yes" -- lxc-info -i -H -n $1)"
    echo ${IP}
    test -n ${IP} && test ${IP} != ${LXCBR0_IP} 
}


get_arch ()
{
    if test $1 = "amd64"; then
	echo "x64"
    elif test $1 = "arm64"; then
	echo "arm64"
    else
	echo "DO IT MANUALLY"
    fi
}

# Necessary because unpriviledged wrappers for lxc in raspbian don't seem to work
lxc_start ()
{
    systemd-run --user --scope -p "Delegate=yes" -- lxc-start $@
}

lxc_attach ()
{
    systemd-run --user --scope -p "Delegate=yes" -- lxc-attach $@
}
