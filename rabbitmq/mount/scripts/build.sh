#!/bin/bash

set -eux

apt-get update &&\
    apt-get install -y --no-install-recommends rabbitmq-server

##################################################################
#/etc/default/rabbitmq-server
#/etc/rabbitmq/rabbitmq-env.conf
#
# ----------------------------------------------------------------
# rabbitmq-env.conf defaults:
# ----------------------------------------------------------------
#
# binds to all interfaces (IPv4 & 6) on port 5672, nodename RABBIT
# leaving these as they are
##################################################################


# In case extra config beyond the defaults are required, create and edit one or both of these
# two files (which are not created by package debian packages)

#[ -f /etc/rabbitmq/rabbitmq.conf ] || touch /etc/rabbitmq/rabbitmq.conf
#[ -f /etc/rabbitmq/advanced.config ] || touch /etc/rabbitmq/advanced.config

# Create user
rabbitmqctl add_user ae-datastore ${RABBIT_PASSWD}

# Create a virtual host
rabbitmqctl add_vhost 1

# Set tags
rabbitmqctl set_user_tags ae-datastore administrator

# Set permissions - allow everything
rabbitmqctl set_permissions --vhost 1 ae-datastore ".*" ".*" ".*"



