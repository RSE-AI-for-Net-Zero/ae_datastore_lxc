#!/bin/bash

set -eux

BIN_PATH="/usr/lib/postgresql/15/bin"
CONFIG_PATH="/etc/postgresql/15/main/postgresql.conf"

apt-get update && \
    apt-get install -y --no-install-recommends postgresql
  
  
chown --recursive postgres:postgres /var/data

cp /home/scripts/config/single-node/postgresql.conf /etc/postgresql/15/main/

chown postgres:postgres /etc/postgresql/15/main/postgresql.conf

echo """
     export PATH=${PATH}:${BIN_PATH}
""" | tee -a /etc/bash.bashrc

#Set a trusted host - e.g., IP address of LXC bridge device lxbr0
echo $'host\tall\tall\t'${TRUSTED_HOST}$'\ttrust' | tee -a /etc/postgresql/15/main/pg_hba.conf

systemctl restart postgresql






