#!/bin/bash

set -eux

BIN_PATH="/usr/lib/postgresql/15/bin"
CONFIG_PATH="/etc/postgresql/15/main/postgresql.conf"

apt-get update && \
    apt-get install -y --no-install-recommends postgresql
  
  chown --recursive postgres:postgres /var/data

echo """
     export PATH=${PATH}:${BIN_PATH}
""" | tee -a /etc/bash.bashrc

systemctl restart postgresql






