#!/bin/bash

set -eux

pg_dropcluster --stop 15 main
pg_createcluster --start 15 ae_data -d /var/data

#Set a trusted host - e.g., IP address of LXC bridge device lxbr0
LINE=$'host\tall\tall\t'${TRUSTED_HOST}$'\ttrust'

if ! grep -Fxq "${LINE}" /etc/postgresql/15/ae_data/pg_hba.conf; then
    echo "${LINE}" | tee -a /etc/postgresql/15/ae_data/pg_hba.conf
fi

sed -ri "s/^#?(listen_addresses)\s*=\s*\S+.*/\1 = '*'/" /etc/postgresql/15/ae_data/postgresql.conf

#systemctl stop postgresql@15-ae_data #advises do this, rather than use pg_ctl stop (or pg_ctlcluster)
su postgres -c 'pg_ctlcluster 15 ae_data stop'
su postgres -c 'pg_ctlcluster 15 ae_data start -- -l ${HOME}/logfile -m smart'


