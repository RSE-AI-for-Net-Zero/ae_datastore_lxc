#!/bin/bash

set -ex

# invenio's almalinux base image sets different permissions:
# (almalinux/Dockerfile)$  chgrp -R 0 ${WORKING_DIR} && chmod -R g=u ${WORKING_DIR}
# (almalinux/Dockerfile)$  useradd invenio --uid ${INVENIO_USER_ID} --gid 0 && \
#                                       chown -R invenio:root ${WORKING_DIR}

# - don't we want invenio to own its data, but not executables?
# - don't we also want to grant uwsgi / nginx minimal permissions?
# - don't see reason for setting group ownership of ${WORKING_DIR} to 0 
# 
# (https://github.com/inveniosoftware/docker-invenio/blob/master/almalinux/Dockerfile)

useradd invenio --shell '/bin/bash' --system --home-dir /opt/invenio
mkdir -p /var/run/celery /var/log/celery /opt/celery
useradd celery --shell '/bin/sh' --system --home-dir /opt/celery
chown --recursive celery:celery /var/run/celery/ /var/log/celery/

# Unsure about permissions here, but this should ensure the volatile /var/run/celery directory
#  gets re-created on each reboot
#
# https://manpages.ubuntu.com/manpages/xenial/en/man5/tmpfiles.d.5.html
touch /etc/tmpfiles.d/celery.conf
echo "d /var/run/celery 0755 celery celery" | tee /etc/tmpfiles.d/celery.conf

cp /home/host/config/etc/systemd/system/celery{,beat}.service /etc/systemd/system
cp /home/host/config/etc/conf.d/celery /etc/conf.d/

systemctl daemon-reload
systemctl enable celery.service celerybeat.service
systemctl start celery.service celerybeat.service
