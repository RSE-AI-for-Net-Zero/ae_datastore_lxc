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

if ( ! container_exists rdm-opensearch-data-1 ) || ${FORCE}
then
    # Mount data directory under var/opensearch/data
    # Mount log directory under var/log/opensearch
    # Builds container
    # Unmounts build directory
    . ./lxc/scripts/opensearch/build_data_node.sh rdm-opensearch-data-1 \
      ${OPENSEARCH_DATA_MOUNT} \
      ${OPENSEARCH_LOG_MOUNT}
fi

if ( ! container_exists rdm-postgresql-1 ) || ${FORCE}
then
    # Set lxc.signal.stop = SIGTERM
    # Mount data directory under var/lib/postgresql/data
    # Builds container
    # Unmounts build directory
    . ./lxc/scripts/postgresql/build.sh rdm-postgresql-1 ${POSTGRESQL_DATA_MOUNT}
fi

if (! container_exists rdm-rabbitmq ) || ${FORCE}
then
    # Builds container
    # Unmounts build directory
    . ./lxc/scripts/rabbitmq/build.sh rdm-rabbitmq
fi







