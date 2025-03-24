-------
Summary
-------

[!ToDo!] What is currently deployed?  RDMv12, except ldap, rdm-records, ae-dataschemas and factory patch.  Link to individual repos.  State versions.
[!ToDo!] Secrets management
[!ToDo!] Single data for opensearch
[!ToDo!] Single node for postgresql

.. _topology_ref:

--------
Topology
--------


[!ToDo!] Make note about SSL termination
[!ToDo!] SESSION_COOKIE_SECURE (warning) - secure headers

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


[!ToDo!] uWSGI services and Celery workers
[!ToDo!] Where are Celery and Celerybeat tasks loaded from

----------------------------------
Switching development & production
----------------------------------

[!ToDo!] Switch rdm-invenio-{ui,api}-{blue,green} service URLs.

[!ToDo!] Switch rdm-invenio-{ui,api}-{blue,green} LDAP access groups.

[!ToDo!] Switch rules in HAProxy.
