^^^^^^^^^^^^^^^^^^^^^^
Summary
^^^^^^^^^^^^^^^^^^^^^^

The containers *rdm-invenio-ui-blue* and *rdm-invenio-ui-green* each host a `uWSGI server <https://uwsgi-docs.readthedocs.io/en/latest/>`_ listening on port 5000 on all interfaces managed by systemd as services defined in :file:`/etc/systemd/system/ui.service`.  The uWSGI config is found in :file:`/etc/uwsgi_ui.ini`, which after adding to or altering you'll need to restart the server::

  systemctl restart ui.service

To check the state of the ui and api services::

  journalctl -xeu ui.service

and you can query the current state of the uWSGI servers using their stats server::

  curl localhost:9000 --http0.9

These containers each additionally host three `Celery <https://docs.celeryq.dev/en/stable/index.html>`_ workers that support the *celery* and *celerybeat* services, defined in :file:`/etc/systemd/system/celery.service` and :file:`/etc/systemd/system/celerybeat.service`.  These are configured in :file:`/etc/conf.d/celery` (e.g., the number of workers). Again, any changes to the config require a restart of the services::

  systemctl restart celery.service celerybeat.service

The celery worker logs are found under :file:`/var/log/celery/`.  

The containers *rdm-invenio-api-blue* and *rdm-invenio-api-green* are very similar to their *ui* counterparts - they handle requests whose patterns match ``/api/.*`` and they host the api service (configured in :file:`/etc/uwsgi_api.ini`, as well as three celery workers.

When the uWSGI server receives a request it hands it over to the Invenio WSGI app produced from the appropriate app factories ``invenio_factory_patch.factory.create_ui`` and ``invenio_factory_patch.factory.create_api``.  These WSGI apps are `InvenioRDM v12.0 <https://inveniosoftware.org/products/rdm/>`_ with adaptations to support our use case.  These are the addition of a Flask/Invenio extension to support authentication and access management via an LDAP client (see `<https://github.ic.ac.uk/aeronautics/invenio-ldapclient>`_) and a set of specialisations of Invenio's records management internal API to allow and extended data model beyond DataCite - effected by a new Invenio extension `invenio-rdm-domain-records` (see `<https://github.ic.ac.uk/aeronautics/invenio-rdm-domain-records>`_), which allows a domain-specific metadata subschema to be loaded from and maintained at `<https://github.ic.ac.uk/aeronautics/ae-datastore-schemas>`_.  Finally, the package `invenio-factory-patch <https://github.ic.ac.uk/aeronautics/invenio-factory-patch>`_ replaces the app factories and various entry points to ensure certain Invenio extensions are loaded in a particular way.

Configuration for these is found in all containers in :file:`/opt/invenio/var/instance/invenio.cfg`.  Again, to effect any changes to these configs will require service restart ::

  systemctl restart ui.service celery.service celerybeat.service

or ::

  systemctl restart api.service celery.service celerybeat.service
  
The outer HAProxy server handles SSL termination and forwards decrypted requests to the domains ``data(-dev).ae.ic.ac.uk`` and ``store(-dev).ae.ic.ac.uk`` to the inner HAProxy instance.  This, in turn forwards requests bound for host ``data.ae.ic.ac.uk`` to *rdm-invenio-ui-blue* or *rdm-invenio-api-blue*, as just described and requests bound for ``data-dev.ae.ic.ac.uk`` to *rdm-invenio-ui-green* or *rdm-invenio-api-green*.

Currently, the outer HAProxy server will return *403 Forbidden* from any requests to data.ae.ic.ac.uk originating from outside of the College network.  To allow "safe" operations, such as download requests, the outer HAProxy *will* forward requests to hosts ``store.ae.ic.ac.uk`` and ``store-dev.ae.ic.ac.uk`` whose url path matches the pattern ``/records/{record_id}/files/{file_key}``.  Allowing additional requests, such as, e.g., requests to the record search endpoint, requires adding more path-matching logic.

Supporting this deployment  

- 2 `redis-server v7.0.5 <https://redis.io/>`_ instances hosted in *rdm-redis(-dev)*
- 2 `rabbitmq-server v3.10.8 <https://www.rabbitmq.com/>`_ instances in *rdm-rabbitmq(-dev)*
- 2 `opensearch v2.15.0 <https://opensearch.org/>`_ data nodes in *rdm-opensearch-d1-(-dev)*
- 2 `postgresql v15.0 <https://www.postgresql.org/>`_ nodes in *rdm-postgresql-1(-dev)*
  
Note that this is just an initial deployment. Some of these services might have to be supplemented with additional nodes as demand grows.  For example, `Opensearch recommend a Coordinating and a Cluster Manager node and two Data Nodes as a basic architecture <https://opensearch.org/docs/2.15/tuning-your-cluster/>`_.  The benefit of separating out the ui from the api services is that these will face different load patterns, with the api service dealing with heavy up/downloads, and so you can give these different levels of resource. E.g., you can add additional replicates of the *rdm-invenio* containers for extra uWSGI services and/or celery workers then let HAProxy handle the load balancing to reduce latency.

Here is a visual summary of all the containers with information about their external file system mounts.
  
.. figure:: /images/second_deployment.drawio.png

   Containers and services in current deployment.  See legend below.

   .. csv-table::
      :header-rows: 1
      :class: longtable

      "Symbol", "mount location (within container) / note"
      "1", "``/opt/invenio/var/instance/data``"
      "2", "``/opt/invenio/var/instance/log``"
      "3",  "``/var/opensearch/data``"
      "4", "``/var/log/opensearch``"
      "5", "``/var/lib/postgres/data``"
      "6", "Checks username in access group **acc-data-repo-dev**"
      "7", "Checks username in access group **acc-data-repo**"

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
``importlib_metadata.entry_points`` and *invenio-factory-patch*
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Invenio makes extensive use of metadata entry points to load all kinds of things

- extension modules via the groups *invenio_base.apps* and *invenio_base.api_apps*
- blueprints (*invenio_base.blueprints* and *invenio_base.api_blueprints*)
- database tables (*invenio_db.models*)
- celery tasks (*invenio_celery.tasks*)

They also give a way to hook into stages of app loading, e.g., *invenio-rdm-domain-records* registers an error handler for *jsonschema* ``ValidationError`` exceptions for the REST API.

To query entry points, do something like this. Start a python interpreter

::

   root@rdm-invenio-ui-green:~# /opt/invenio/src/.venv/bin/python

::

   >>> from importlib_metadata import entry_points
   >>> for _ in sorted(entry_points(group = "invenio_db.models")): print(_)

As convenient as entry points are, they're a real pain when there's something you **don't** want loading, or you need to be sure that a certain extension is always loaded before others, such as *invenio-ldapclient* (which must load before *invenio-accounts* because it sets certain config values that affect the latter).  This is why `invenio-factory-patch <https://github.ic.ac.uk/aeronautics/invenio-factory-patch>`_ exists.





  
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Development & production - how to switch
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Currently, green = "dev" and blue = "production".  To switch these over (**important** test this before doing it in production)

1. switch over the external filesystem mounts at :file:`/opt/invenio/var/data` and :file:`/opt/invenio/var/log` in each of the containers, so that
   
   - */invenio-data-dev* and */invenio-log-dev* are mounted in *rdm-invenio-blue-ui* and *rdm-invenio-blue-api* and
   - */invenio-data* and */invenio-log* are mounted in *rdm-invenio-green-ui* and *rdm-invenio-green-api*

2. switch each of the service URLs to point appropriately to *service*-dev or *service* .  These are assigned to keys in :file:`invenio.cfg` - change them for both the UI and API containers

   - ``SQLALCHEMY_DATABASE_URI``
   - ``SQLALCHEMY_DATABASE_URI``
   - ``CACHE_REDIS_URL``
   - ``ACCOUNTS_SESSION_REDIS_URL``
   - ``CELERY_RESULT_BACKEND``
   - ``RATELIMIT_STORAGE_URL``
   - ``COMMUNITIES_IDENTITIES_CACHE_REDIS_URL``
   - ``IIIF_CACHE_REDIS_URL``
   - ``BROKER_URL``
   - ``CELERY_BROKER_URL``
   - ``SEARCH_HOSTS``

3. switch LDAP access group filters, in the key (also in :file:`invenio.cfg` - again, do it for both UI and API)

   - ``LDAPCLIENT_GROUP_SEARCH_FILTERS``

4. finally, switch the routing rules for the inner HAProxy for

   - *store(-dev).ae.ic.ac.uk*
   - *data(-dev).ae.ic.ac.uk*
