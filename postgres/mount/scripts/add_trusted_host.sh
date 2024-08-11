#!/bin/bash

set -eux

TRUSTED_HOST=$_TRUSTED_HOST

# Smart shutdown
su postgres -c 'pg_ctlcluster --mode smart 15 ae_data stop --skip-systemctl-redirect'

#Set a trusted host - e.g., IP address of LXC bridge device lxbr0, or app container
LINE=$'host\tall\tall\t'${TRUSTED_HOST}$'\ttrust'

if ! grep -Fxq "${LINE}" /etc/postgresql/15/ae_data/pg_hba.conf; then
    echo "${LINE}" | tee -a /etc/postgresql/15/ae_data/pg_hba.conf
fi

su postgres -c 'pg_ctlcluster 15 ae_data start'


