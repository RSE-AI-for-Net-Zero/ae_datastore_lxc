#!/bin/bash

# BEFORE this script:
#   SSL certs & keys are in ./ssl/certs ./ssl/keys
#   UID 0 inside container has rw permissions for data and log volumes

source ./lxc/build.conf
source ./lxc/scripts/create_container.sh
source ./scripts/secrets.sh

FORCE=false

export CONTAINER_CONFIG
export PREFIX

export LXC_DIST
export LXC_REL
export LXC_ARCH
export LXCBR0_IP
export LXC_UNPRIV_DIR
export NODE_SUFFIX

APP_BASE_NAME=ae-datastore

     
if ( ! container_exists rdm-opensearch-data-1 ) || ${FORCE}
then
    # Mount data directory
    # Mount log directory
    # Build container
    # Unmount build directory
    . ./lxc/scripts/opensearch/build_data_node.sh rdm-opensearch-data-1 \
      ${OPENSEARCH_DATA_MOUNT} ${OPENSEARCH_LOG_MOUNT}
fi

if ( ! container_exists rdm-postgresql-1 ) || ${FORCE}
then
    # Set lxc.signal.stop = SIGTERM
    # Mount data directory
    # Build container
    # Unmount build directory
    . ./lxc/scripts/postgresql/build.sh rdm-postgresql-1 ${POSTGRESQL_DATA_MOUNT}
fi

if ( ! container_exists rdm-rabbitmq ) || ${FORCE}
then
    # Build container
    # Unmount build directory
    . ./lxc/scripts/rabbitmq/build.sh rdm-rabbitmq
fi

if ( ! container_exists rdm-redis ) || ${FORCE}
then
    # Build container
    # Unmount build directory
    . ./lxc/scripts/redis/build.sh rdm-redis
fi

if ( ! container_exists ${APP_BASE_NAME} ) || ${FORCE}
then
    # Build container
    # Mount data directory
    # Mount log directory
    # Unmount build directory
    # TO DO: set correct container-stop signal
    . ./lxc/scripts/app/build_base_container.sh ${APP_BASE_NAME} \
      ${AE_DATASTORE_DATA_MOUNT} ${AE_DATASTORE_LOG_MOUNT}
      
fi

if ( ! container_exists "${APP_BASE_NAME}-app" ) || ${FORCE}
then
    # Copy base container
    # Remove unmount base build directory
    # Mount ui build directory
    # Build container
    # Unmount ui build directory
    . ./lxc/scripts/app/build_ui_container.sh ${APP_BASE_NAME}
fi

# Containers can resolve hostnames: rdm-redis, etc.
# - add some-container,10.0.3.101 ---> /etc/lxc/dnsmasq-hosts.conf
# - add dhcp-hostsfile=/etc/lxc/dnsmasq-hosts.conf ---> /etc/lxc/dnsmasq.conf
# - add LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf ---> /etc/default/lxc
# - sudo rm /var/lib/misc/<dnsmasq.lease.file> (or delete any existing leases for rel. containers)
# - sudo systemctl restart lxc-net


# ae-datastore-app added as trusted host for postgresql container(s)
# export INVENIO_INSTANCE_PATH=/opt/invenio/var/instance
# RABBIT and OS passwords in environ
# source /opt/invenio/scripts/setup_services.sh
# _cleanup
# 



















