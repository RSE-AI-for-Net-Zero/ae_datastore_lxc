#!/bin/bash

set -ex

useradd celery --shell '/bin/sh' --system --home-dir /opt/celery
mkdir -p /var/run/celery /var/log/celery /opt/celery/var

# Unsure about permissions here, but this should ensure the volatile /var/run/celery directory
#  gets re-created on each reboot
#
# https://manpages.ubuntu.com/manpages/xenial/en/man5/tmpfiles.d.5.html
touch /etc/tmpfiles.d/celery.conf
echo "d /var/run/celery 0755 celery celery" | tee /etc/tmpfiles.d/celery.conf

cp --recursive /home/host/ui/config/etc/* /etc
chown --recursive celery:celery /var/log/celery /var/run/celery /opt/celery

echo $'\n'"RABBIT_PASSWD=\"${RABBIT_PASSWD}\""\
     $'\n'"OPENSEARCH_AEDATASTORE_PASSWD=\"${OPENSEARCH_AEDATASTORE_PASSWD}\""$'\n' |\
    tee -a /etc/conf.d/celery


systemctl daemon-reload
systemctl enable celery.service celerybeat.service
systemctl start celery.service celerybeat.service

# invenio's almalinux base image sets different permissions:
# (almalinux/Dockerfile)$  chgrp -R 0 ${WORKING_DIR} && chmod -R g=u ${WORKING_DIR}
# (almalinux/Dockerfile)$  useradd invenio --uid ${INVENIO_USER_ID} --gid 0 && \
#                                       chown -R invenio:root ${WORKING_DIR}

# - don't we want invenio to own its data, but not executables?
# - don't we also want to grant uwsgi / nginx minimal permissions?
# - don't see reason for setting group ownership of ${WORKING_DIR} to 0 
# 
# (https://github.com/inveniosoftware/docker-invenio/blob/master/almalinux/Dockerfile)

#useradd ae-datastore --shell '/bin/sh' --system --home-dir /opt/invenio
#chown --recursive ae-datastore:ae-datastore /opt/invenio/var/instance/data









# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#export CREDENTIALS_DIRECTORY="/etc/credentials"
#mkdir ${CREDENTIALS_DIRECTORY}


#echo ${RABBIT_PASSWD} | tee ${CREDENTIALS_DIRECTORY}/rabbit.psswd
#echo ${OPENSEARCH_AEDATASTORE_PASSWD} |\
#    tee ${CREDENTIALS_DIRECTORY}/opensearch_aedatastore.psswd

#chown --recursive root:root ${CREDENTIALS_DIRECTORY}
#chmod --recursive 400 ${CREDENTIALS_DIRECTORY}
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
