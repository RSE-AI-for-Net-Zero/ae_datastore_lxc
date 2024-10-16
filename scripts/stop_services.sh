#!/bin/bash

for s in rabbitmq redis ae-datastore-app ldap
do lxc-stop  -n $s
done
