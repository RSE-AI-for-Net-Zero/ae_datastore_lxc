-------
Summary
-------

[!ToDo!] What is currently deployed?  RDMv12, except ldap, rdm-records, ae-dataschemas and factory patch.  Link to individual repos.  State versions.

--------
Topology
--------

[!ToDo!] Make note about SSL termination
[!ToDo!] SESSION_COOKIE_SECURE (warning) - secure headers

.. figure:: /images/second_deployment.drawio.png

   Containers and services in current deployment.  See legend below.

   .. csv-table::
      :header-rows: 1		  

      "Symbol", "mount location (within container) / note"
      "1", "``/opt/invenio/var/instance/data``"
      "2", "``/opt/invenio/var/instance/log``"                  
      "3", "Checks username in access group `[!TO DO!]`"
      "4", "``/var/opensearch/data``"             
      "5", "``/var/log/opensearch``"             
      "6", "``/var/lib/postgres/data``"             
      "7", "Checks username in access group `acc-data-repo`"             
     

[!ToDo!] Diagram where data. data-dev. store. and store-dev. are pointing

----------------------------------
Switching development & production
----------------------------------

[!ToDo!] Switch rdm-invenio-{ui,api}-{blue,green} service URLs.

[!ToDo!] Switch rdm-invenio-{ui,api}-{blue,green} LDAP access groups.

[!ToDo!] Switch rules in HAProxy.
