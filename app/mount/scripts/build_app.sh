#!/bin/bash

# https://github.com/inveniosoftware/docker-invenio/blob/master/almalinux/Dockerfile

set -eux

export WORKING_DIR=/opt/invenio
export INVENIO_INSTANCE_PATH=${WORKING_DIR}/var/instance

mkdir -p ${INVENIO_INSTANCE_PATH} && \
    mkdir ${INVENIO_INSTANCE_PATH}/data \
	  ${INVENIO_INSTANCE_PATH}/archive \
	  ${INVENIO_INSTANCE_PATH}/static \
	  ${WORKING_DIR}/src

export INVENIO_USER_ID=999

chgrp -R 0 ${WORKING_DIR} && \
    chmod -R g=u ${WORKING_DIR}

useradd invenio --uid ${INVENIO_USER_ID} --gid 0 && \
    chown -R invenio:root ${WORKING_DIR}

apt-get update && apt-get install -y imagemagick
