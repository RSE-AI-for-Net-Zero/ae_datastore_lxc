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

[!ToDo!] Make note about reverse DNS lookup
And then add container IPv4 & 6 addresses to `/etc/hosts`, e.g.,::

  echo """
  10.48.175.211	                                rdm-invenio-ui
  fd42:5d08:8368:96ec:216:3eff:fe88:e19e	rdm-invenio-ui

  10.48.175.211	                                rdm-invenio-api
  fd42:5d08:8368:96ec:216:3eff:fe88:e19e	rdm-invenio-api
  """ | tee -a /etc/hosts


Query list of databases::

  su postgres -c "psql -l"


pg_hba.conf
-----------

Attempts to connect to the PG server from the rdm-invenio-**-** containers are failing when `pg_hba.conf` uses host names.  Postgresql docs say `here <https://www.postgresql.org/docs/15/auth-pg-hba-conf.html>`_ that when host names (rather than IP address ranges) are specified, that each host name `"... is compared with the result of a reverse name resolution of the client's IP address (e.g., reverse DNS lookup, if DNS is used). Host name comparisons are case insensitive. If there is a match, then a forward name resolution (e.g., forward DNS lookup) is performed on the host name to check whether any of the addresses it resolves to are equal to the client's IP address. If both directions match, then the entry is considered to match."`



Use SQLAlchemy to attempt a connection::
----------------------------------------

Start python interpreter in rdm-invenio-api-{blue,green}::

  /opt/invenio/src/.venv/bin/python

::

   >>> from sqlalchemy import create_engine
   >>> URL = "postgresql://postgres:postgres@rdm-postgresql-1-dev/ae-data"
   >>> create_engine(URL).connect()


Check log file in rdm-postgresql-1-dev::

  cat /var/lib/postgresql/data/log/postgresql-2025- ... .log

  ... FATAL:  no pg_hba.conf entry for host "10.48.175.35", user "postgres",
      database "ae-data", no encryption
  ... DETAIL:  Client IP address resolved to "rm-invenio-api-blue",
      forward lookup not checked.


::

   root@rdm-postgresql-1:/# pg_isready
   /var/run/postgresql:5432 - no response
   root@rdm-postgresql-1:/# su postgres -c "pg_ctlcluster 15 ae_data start"
   Error: Data directory /var/lib/postgresql/data must not be owned by root
   root@rdm-postgresql-1:/# ls -lah /var/lib/postgresql
   total 6.0K
   drwxr-xr-x  3 postgres postgres    3 Nov 19 13:59 .
   drwxr-xr-x 14 root     root       15 Mar 18 18:04 ..
   drwxr-xr-x 20 root     root     4.0K Mar 18 18:03 data
   root@rdm-postgresql-1:/# chown -R postgres:postgres /var/lib/postgresql/data/
   root@rdm-postgresql-1:/# su postgres -c "pg_ctlcluster 15 ae_data start"
   Warning: the cluster will not be running as a systemd service. Consider using systemctl:
   sudo systemctl start postgresql@15-ae_data
   Error: /usr/lib/postgresql/15/bin/pg_ctl /usr/lib/postgresql/15/bin/pg_ctl start -D /var/lib/postgresql/data -l /var/log/postgresql/postgresql-15-ae_data.log -s -o  -c config_file="/etc/postgresql/15/ae_data/postgresql.conf"  exited with status 1: 
   2025-03-20 10:01:34.634 UTC [918] FATAL:  data directory "/var/lib/postgresql/data" has invalid permissions
   2025-03-20 10:01:34.634 UTC [918] DETAIL:  Permissions should be u=rwx (0700) or u=rwx,g=rx (0750).
   pg_ctl: could not start server
   Examine the log output.
   root@rdm-postgresql-1:/# ls -lah /var/lib/postgresql
   total 6.0K
   drwxr-xr-x  3 postgres postgres    3 Nov 19 13:59 .
   drwxr-xr-x 14 root     root       15 Mar 18 18:04 ..
   drwxr-xr-x 20 postgres postgres 4.0K Mar 18 18:03 data
   root@rdm-postgresql-1:/# chmod o-rx /var/lib/postgresql/data
   root@rdm-postgresql-1:/# su postgres -c "pg_ctlcluster 15 ae_data start"
   Warning: the cluster will not be running as a systemd service. Consider using systemctl:
   sudo systemctl start postgresql@15-ae_data




  



  





