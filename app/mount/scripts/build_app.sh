#!/bin/bash

set -eux

export WORKING_DIR=/opt/invenio
export INVENIO_INSTANCE_PATH=${WORKING_DIR}/var/instance
export INVENIO_USER_ID=1001

apt-get update && apt-get install -y libcairo2

mkdir -p ${WORKING_DIR}/src

chgrp -R 0 ${WORKING_DIR} && \
    chmod -R g=u ${WORKING_DIR}

useradd invenio --uid ${INVENIO_USER_ID} --gid 0 && \
    chown -R invenio:root ${WORKING_DIR}

cd /tmp && git clone https://github.com/AI-for-Net-Zero/ae-datastore.git && \
    cd ${WORKING_DIR}/src && \
    TMP_ROOT=/tmp/ae-datastore/ae-datastore

cp --recursive ${TMP_ROOT}/. .  
pip install invenio-cli --root-user-action ignore
invenio-cli install --no-dev --production



