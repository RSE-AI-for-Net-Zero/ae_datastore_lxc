#!/bin/bash

for s in rabbitmq redis ae-datastore-app ldap
do lxc-unpriv-start -n $s
done
