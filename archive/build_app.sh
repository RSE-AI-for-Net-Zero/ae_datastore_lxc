#!/bin/bash

set -eux

apt-get update && apt-get install -y libcairo2

export WORKING_DIR=/opt/invenio
export INVENIO_INSTANCE_PATH=${WORKING_DIR}/var/instance

mkdir -p ${WORKING_DIR}/src \
      ${INVENIO_INSTANCE_PATH}/archive \
      ${INVENIO_INSTANCE_PATH}/static


mkdir -p /etc/conf.d

cd /tmp && git clone https://github.com/AI-for-Net-Zero/ae-datastore.git && \
    cd ${WORKING_DIR}/src && \
    cp --recursive /tmp/ae-datastore/ae-datastore/* .


# We're now mimicking the steps executed by invenio-cli install --no-dev --production.
# However, in spite of --production --no-dev options, invenio-cli still seems to symlink templates and
# app_data directories into instance folder.  This seems dodgy in production.  Intention is to limit
# priviledges of process running uwsgi to access what is in the <instance> directory.

# 1. - call cli.install.(cli_config, pre=False, dev=False, production=True)
# 1.1 - calls commands = InstallCommand(cli_config)
# 1.2 - calls steps = commands.install(pre=False, dev=False, flask_env='production')
# 1.3 - calls run_steps(steps, ...)

# 1.2.1 - install_py_dependencies(False, False)
# 1.2.1.1 - PackagesCommands.is_locked ? Yes, Pipfile.lock shipped in repo
# 1.2.1.2 - Packages commands install locked deps(False, False)
# ---> CommandStep(["pipenv", "sync"]

# Ssh!
export PIPENV_VERBOSITY="-1"
# Tell pipenv to create venv in the current directory
export PIPENV_VENV_IN_PROJECT=1
pipenv sync


# 1.2.2 - update_instance_path - only affects config - pass
# 1.2.3 - copy invenio.cfg
cp ${PWD}/invenio.cfg ${INVENIO_INSTANCE_PATH}/invenio.cfg

# 1.2.4 - copy templates/
cp --recursive ${PWD}/templates/ ${INVENIO_INSTANCE_PATH}/templates

# 1.2.5 - copy templates/ app_data/
cp --recursive ${PWD}/app_data/ ${INVENIO_INSTANCE_PATH}/app_data

# 1.2.6 - update_statics_and_assets(force=True, flask_env='production', log_file=None)
pipenv run invenio collect --verbose
pipenv run invenio webpack clean create
pipenv run invenio webpack install
cp --recursive static/* ${INVENIO_INSTANCE_PATH}/static
cp --recursive assets/* ${INVENIO_INSTANCE_PATH}/assets

## invenio-cli then goes and symlinks ./assets/* to their corresponding files in <instance_path/assets
##  Why?  Not sure yet.
pipenv run invenio webpack build

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

# Remove pipenv
pip uninstall -y pipenv




####################
#### To do ##

### Ownerships and permissions for /opt/invenio
# chown --recursive invenio:invenio ${INVENIO_INSTANCE_PATH}





