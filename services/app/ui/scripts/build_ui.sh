#!/bin/bash

# invenio's almalinux base image these permissions for WORKING_DIR=/opt/invenio:
# (almalinux/Dockerfile)$  chgrp -R 0 ${WORKING_DIR} && chmod -R g=u ${WORKING_DIR}
# (almalinux/Dockerfile)$  useradd invenio --uid ${INVENIO_USER_ID} --gid 0 && \
#                                       chown -R invenio:root ${WORKING_DIR}
# 
# (https://github.com/inveniosoftware/docker-invenio/blob/master/almalinux/Dockerfile)

set -ex

RABBIT_PASSWD=$1
OPENSEARCH_AEDATASTORE_PASSWD=$2

useradd celery --shell '/bin/sh' --system --no-create-home
useradd ae-datastore --shell '/bin/sh' --system --no-create-home

groupadd secrets 

usermod -aG secrets celery
usermod -aG secrets ae-datastore

mkdir -p /var/run/celery /var/log/celery /opt/celery/var

# Unsure about permissions here, but this should ensure the volatile /var/run/celery directory
#  gets re-created on each reboot
#
# https://manpages.ubuntu.com/manpages/xenial/en/man5/tmpfiles.d.5.html
touch /etc/tmpfiles.d/celery.conf
echo "d /var/run/celery 0755 celery celery" | tee /etc/tmpfiles.d/celery.conf

cp --recursive /home/host/config/* /

chown --recursive celery:celery /var/log/celery /var/run/celery /opt/celery

echo $'\n'"RABBIT_PASSWD=\"${RABBIT_PASSWD}\""\
     $'\n'"OPENSEARCH_AEDATASTORE_PASSWD=\"${OPENSEARCH_AEDATASTORE_PASSWD}\""$'\n' |\
    tee  /etc/conf.d/secrets

chgrp secrets /etc/conf.d/secrets
chmod 640 /etc/conf.d/secrets
chgrp -R ae-datastore /opt/invenio/var
chmod -R g+w /opt/invenio/var

mkdir /opt/invenio/scripts

cp /home/host/scripts/setup_services.sh /opt/invenio/scripts/
chmod 400 /opt/invenio/scripts/setup_services.sh

chown celery:celery /opt/invenio/src/.venv/bin/celery

systemctl daemon-reload
systemctl enable celery.service celerybeat.service app.service
systemctl start celery.service celerybeat.service app.service
