DISTR="debian"
RELEA="bookworm"
ARCHE="arm64"


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
    FULL_NAME=$1"_"${DISTR}"_"${RELEA}"_"${ARCHE}
    CONFIG=$2
    lxc-create -n $FULL_NAME -t download -f ${CONFIG} -- -d ${DISTR} -r ${RELEA} -a ${ARCHE}
}

container_has_ipv4 () 
{
    test -n "`systemd-run --user --scope -p "Delegate=yes" -- lxc-info -i -n $1`"
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


