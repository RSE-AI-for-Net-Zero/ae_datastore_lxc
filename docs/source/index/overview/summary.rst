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

Configuration for these is found in all containers in :file:`/opt/invenio/var/instance/invenio.cfg`.  Again, to effect any changes to these configs will require service restart::

  systemctl restart ui.service celery.service celerybeat.service

or::

  systemctl restart api.service celery.service celerybeat.service
  
The outer HAProxy server handles SSL termination and forwards decrypted requests to the domains ``data(-dev).ae.ic.ac.uk`` and ``store(-dev).ae.ic.ac.uk`` to the inner HAProxy instance.  This, in turn forwards requests bound for host ``data.ae.ic.ac.uk`` to *rdm-invenio-ui-blue* or *rdm-invenio-api-blue*, as just described and requests bound for ``data-dev.ae.ic.ac.uk`` to *rdm-invenio-ui-green* or *rdm-invenio-api-green*.

Currently, the outer HAProxy server will return *403 Forbidden* from any requests to data.ae.ic.ac.uk originating from outside of the College network.  To allow "safe" operations, such as download requests, the outer HAProxy *will* forward requests to hosts ``store.ae.ic.ac.uk`` and ``store-dev.ae.ic.ac.uk`` whose url path matches the pattern ``/records/{record_id}/files/{file_key}``.  Allowing additional requests, such as, e.g., requests to the record search endpoint, requires adding more path-matching logic.

Supporting this deployment  

- 2 `redis-server v7.0.5 <https://redis.io/>`_ instances hosted in *rdm-redis(-dev)*
- 2 `rabbitmq-server v3.10.8 <https://www.rabbitmq.com/>`_ instances in *rdm-rabbitmq(-dev)*
- 2 `opensearch v2.15.0 <https://opensearch.org/>`_ data nodes in *rdm-opensearch-d1-(-dev)*
- 2 `postgresql v15.0 <https://www.postgresql.org/>`_ nodes in *rdm-postgresql-1(-dev)*
  
Note that this is just an initial deployment. Some of these services might have to be supplemented with additional nodes as demand grows.  For example, `Opensearch recommend a Coordinating and a Cluster Manager node and two Data Nodes as a basic architecture <https://opensearch.org/docs/2.15/tuning-your-cluster/>`_.  The benefit of separating out the ui from the api services is that these will face different load patterns, with the api service dealing with heavy up/downloads, and so you can give these different levels of resource. E.g., you can add additional replicates of the *rdm-invenio* with extra uWSGI services and/or celery workers and letting HAProxy handle the load balancing will reduce latency.

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



^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Development & production - how to switch
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. [!ToDo!] Switch rdm-invenio-{ui,api}-{blue,green} service URLs.

.. [!ToDo!] Switch rdm-invenio-{ui,api}-{blue,green} LDAP access groups.

.. [!ToDo!] Switch rules in HAProxy.
