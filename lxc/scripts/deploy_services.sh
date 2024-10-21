#!/bin/bash

# BEFORE this script:
#   SSL certs & keys are in ./ssl

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

APP_BASE_NAME=test-ae-datastore


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




