.. _postgresql_ref:

----------
Postgresql
----------

To make upgrading postgres easier, the Debian package creators have provided a set of wrappers around Postgres's command line tools - `see here <https://wiki.debian.org/PostgreSql#pg_ctl_replacement>`_

In fact it's worth reading the entire `Debian wiki <https://wiki.debian.org/PostgreSql>`_

Use SQLAlchemy to attempt a connection ::
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Start python interpreter in *rdm-invenio-api-{blue,green}* ::

  /opt/invenio/src/.venv/bin/python

::

   >>> from sqlalchemy import create_engine
   >>> URL = "postgresql://postgres:postgres@rdm-postgresql-1-dev/ae-data"
   >>> create_engine(URL).connect()

   
Where are the log files?
^^^^^^^^^^^^^^^^^^^^^^^^
::
   
  cat /var/lib/postgresql/data/log/postgresql-2025- ... .log

  ... FATAL:  no pg_hba.conf entry for host "10.48.175.35", user "postgres",
      database "ae-data", no encryption
  ... DETAIL:  Client IP address resolved to "rm-invenio-api-blue",
      forward lookup not checked.


Permissions for ``/var/lib/postgresql/data``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Postgres has requirements about directory permissions ::

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




  



  





