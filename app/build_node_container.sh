BASE_NAME=$1 #'python39_debian_bookworm_amd64'
FULL_NAME="nodejs_"${BASE_NAME}

. ../create_container.sh

NODE_VER='v20.9.0'
NODE_ARCH=`get_arch ${ARCHE}`
export NODE_SUFF='tar.xz'
NODE_PATH='https://nodejs.org/download/release'

export NODE_URL_PATH=${NODE_PATH}"/"${NODE_VER}
export NODE_PACKAGE="node-"${NODE_VER}"-linux-"${NODE_ARCH}


systemd-run --user --scope -p "Delegate=yes" -- lxc-copy -n ${BASE_NAME} -N ${FULL_NAME}

systemd-run --user --scope -p "Delegate=yes" -- lxc-start -n ${FULL_NAME}

echo "waiting for IP addr"
sleep 1

while ! container_has_ipv4 ${FULL_NAME} -i; do
    echo "waiting for IP addr"
    sleep 1
done

systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n ${FULL_NAME} --clear-env \
	    --keep-var NODE_URL_PATH \
	    --keep-var NODE_PACKAGE \
	    --keep-var NODE_SUFF \
	    -- /home/host/scripts/build_node_npm.sh

systemd-run --user --scope -p "Delegate=yes" -- lxc-stop -n ${FULL_NAME}




