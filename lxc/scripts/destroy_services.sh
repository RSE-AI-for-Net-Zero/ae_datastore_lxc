#!/bin/bash

source ./lxc/scripts/create_container.sh

for s in rdm-rabbitmq rdm-redis ae-datastore-app rdm-opensearch-data-1 rdm-postgresql-1
do
    lxc-destroy -n $s
done
