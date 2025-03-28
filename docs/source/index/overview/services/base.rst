.. _basecontainer_ref:

Invenio UI and API
------------------

  
How do I update a package?
^^^^^^^^^^^^^^^^^^^^^^^^^^

stop the service ::

  root@rdm-invenio-ui-green:~# systemctl stop ui.service

and / or (it depends on whether the update will affect one or other or both) ::

  root@rdm-invenio-api-green:~# systemctl stop api.service

activate virtual env and uninstall ::

  root@rdm-invenio-ui-green:~# . /opt/invenio/src/.venv/bin/activate
  (src) root@rdm-invenio-ui-green:~# pip uninstall <name-of-package>

then do something like ::

  (src) root@rdm-invenio-ui-green:~# pip install "git+https://github.ic.ac.uk/aeronatics/<name-of-package>.git

or if we're installing from pyPI ::

  (src) root@rdm-invenio-ui-green:~# pip install <name-of-package>
  (src) root@rdm-invenio-ui-green:~# deactivate
  
Then restart the service ::

  root@rdm-invenio-ui-green:~# systemctl restart ui.service
  
  
