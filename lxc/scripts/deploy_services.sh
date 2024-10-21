#!/bin/bash

# BEFORE this script:
#   SSL certs & keys are in ./ssl
#   build.conf has been sourced

source ./lxc/scripts/create_container.sh
source ./scripts/secrets.sh

. ./lxc/scripts/opensearch/build_data_node.sh opensearch_d1 \
  ${OPENSEARCH_DATA_MOUNT} \
  ${OPENSEARCH_LOG_MOUNT}







