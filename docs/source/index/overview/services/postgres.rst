.. _postgresql_ref:

==============
Postgresql
==============

Data dir (on host)

::
   
   chown 100000:100000 /path/to/host/data/dir


Build rdm-postgresql-*
----------------------

::

   apt-get update && apt-get -y install git
   mkdir -p /root/host /var/lib/postgres/data
   cd /tmp
   git clone https://github.com/RSE-AI-for-Net-Zero/ae_datastore_lxc.git
   cd ae_datastore_lxc
   git checkout <branch>
   mv services/postgresql/* /root/host/
   cd /
   ./root/host/scripts/build_node.sh

Add trusted hosts::

  mv /root/host/scripts/add_trusted_host.sh /usr/local/bin
  add_trusted_host.sh rdm-invenio-ui
  add_trusted_host.sh rdm-invenio-api

And then add container IPv4 & 6 addresses to `/etc/hosts`, e.g.,::

  echo """
  10.48.175.211	                                rdm-invenio-ui
  fd42:5d08:8368:96ec:216:3eff:fe88:e19e	rdm-invenio-ui

  10.48.175.211	                                rdm-invenio-api
  fd42:5d08:8368:96ec:216:3eff:fe88:e19e	rdm-invenio-api
  """ | tee -a /etc/hosts




