========================
Opensearch
========================

------------------------
Installation
------------------------

------------------------
Security configuration
------------------------

Configuration files, kept under version control, are found in ``opensearch/mount/config/.../``.  These will set an initial configuration.  To effect changes to these after initialisation, see :ref:`lab-opensearch_update_config`.




.. _lab-opensearch_update_config:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Updating configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Edit the files in ``opensearch/mount/config/.../``, then run

::

   systemd-run --user --scope -p "Delegate=yes" -- \
   lxc-attach --clear-env -n opensearch_d1_debian_bookworm_arm64 -- \
   /home/host/scripts/reconfigure_security.sh


This copies the config files to the appropriate location inside the container's ``/etc`` directory, sets their permissions, runs OpenSearch's `securityadmin.sh` script then restarts the server.

Configuration of a live cluster can also be done via the REST API using admin credentials.

------------------------
Some common API commands
------------------------

^^^^^^^^^^^^^^^^
e.g., with `curl`
^^^^^^^^^^^^^^^^
::
   
  curl -X POST -k -u 'invenio_usr:password_1234' \
  https://raspberryPi:9200/cats/_doc \
  -H "Content-type: application/json" \
  -d '{"name": "Snowy", "Favourite toy": "Ball of wool"}'

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
e.g., with Python's `requests`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  

^^^^^^^^^^^^^^^^
Create an index
^^^^^^^^^^^^^^^^

See `docs <https://opensearch.org/docs/2.15/api-reference/index-apis/create-index/>`_

::
   
  PUT <index-name>

^^^^^^^^^^^^^^^^
Index a document
^^^^^^^^^^^^^^^^

See `docs <https://opensearch.org/docs/2.15/api-reference/document-apis/index-document/>`_

Index (or update) a document with specific id::

  PUT <index-name>/_doc/<id> {...}

Auto-generate id::

  POST <index-name>/_doc/ {...}

