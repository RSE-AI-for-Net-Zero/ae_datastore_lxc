#!/bin/bash

set -eux

#BIN_PATH="/usr/lib/postgresql/15/bin"
CONFIG_PATH="/etc/postgresql/15/main"

apt-get update && \
    apt-get install -y --no-install-recommends postgresql
  
  
#chown --recursive postgres:postgres /var/data

cp config/single-node/postgresql.conf $CONFIG_PATH/

chown postgres:postgres $CONFIG_PATH/postgresql.conf

#echo """
#     export PATH=${PATH}:${BIN_PATH}
#""" | tee -a /etc/bash.bashrc

#Set a trusted host - e.g., IP address of LXC bridge device lxbr0
#echo $'host\tall\tall\t'${TRUSTED_HOST}$'\ttrust' | tee -a $CONFIG_PATH/pg_hba.conf
echo -e "host\tall\t\tall\t0.0.0.0/0\ttrust" >> $CONFIG_PATH/pg_hba.conf
systemctl restart postgresql






