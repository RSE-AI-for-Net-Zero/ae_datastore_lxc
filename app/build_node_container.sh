BASE_NAME=$1 #'python39_debian_bookworm_amd64'
FULL_NAME="node_16_npm_7_"${BASE_NAME}

. ../create_container.sh

systemd-run --user --scope -p "Delegate=yes" -- lxc-copy -n ${BASE_NAME} -N ${FULL_NAME}

systemd-run --user --scope -p "Delegate=yes" -- lxc-start -n ${FULL_NAME}

echo "waiting for IP addr"
sleep 1

while ! container_has_ipv4 ${FULL_NAME} -i; do
    echo "waiting for IP addr"
    sleep 1
done

systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n ${FULL_NAME} --clear-env \
	    -- /home/scripts/build_node_npm.sh


