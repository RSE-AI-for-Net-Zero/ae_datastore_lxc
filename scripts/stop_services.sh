#!/bin/bash

for s in rabbitmq redis ae-datastore-ui ldap2_debian_bookworm_amd64
do lxc-stop  -n $s
done
