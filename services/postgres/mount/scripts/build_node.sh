#!/bin/bash

set -eux

BIN_PATH="/usr/lib/postgresql/15/bin"
CONFIG_PATH="/etc/postgresql/15/main/postgresql.conf"

apt-get update && \
    apt-get install -y --no-install-recommends postgresql
  

echo """
     export PATH=${PATH}:${BIN_PATH}
""" | tee -a /etc/bash.bashrc


chown --recursive postgres:postgres /var/lib/postgres

# Drop default cluster
pg_dropcluster --stop 15 main 

# Initialise new cluster in mounted data dir
pg_createcluster 15 ae_data -d /var/lib/postgres/data -- -E UTF-8

# Move config file to where cluster reads from
cp /home/host/config/single-node/postgresql.conf /etc/postgresql/15/ae_data/

# Make sure postgres usr owns the config
chown postgres:postgres /etc/postgresql/15/ae_data/postgresql.conf

# Start the cluster
su postgres -c 'pg_ctlcluster 15 ae_data start'











