Work flow (dev)
===============

Assuming that OpenSearch, PostgreSQL, rabbitmq, redis & LDAP servers have been built and are up

1. Set up storage
-----------------
User ``lxc`` has host uid 100000 is mapped to uid 0 (root) inside lxc containers, i.e.,

::

   (host) $: cat /etc/subuid
   ... leeb:100000:65536
   
   (host) $: cat /etc/subgid
   ... leeb:100000:65536

   (host) $: cat ae_datastore_lxc/lxc_config.conf
   ...
   lxc.idmap = u 0 100000 65536
   lxc.idmap = g 0 100000 65536

   
Prepare local storage location on host

::

   (host) $: mkdir -p <storage_root>/ae-datastore/data
   (host) $: sudo chown -R lxc:lxc <storage_root>/ae-datastore

2. Build base container
-----------------------
Create an unpriviledged base container with host storage location mounted inside at ``/opt/invenio/var/instance/data``. 
::
   
   (host) $: cd ae_datastore_lxc/app
   (host) $: . build_base_container.sh ae-datastore ../lxc_config.conf \
         <storage_root>/ae-datastore/data

Then, inside the container, run the build script, which
   - installs ``pyenv``
   - uses ``pyenv`` to install ``python 3.9`` (version required by ``invenio-add-rdm v11.0``) and sets this as global python version.  This is quicker and easier than building interpreter from source
   - downloads, unpacks and installs ``node v20.9.0`` from a pre-built binary for ``linux x64`` (set environment variable ``NODE_SUFFIX`` to alter this behaviour).  *Note* this specific version of node contains the version of ``npm`` required by ``invenio-add-rdm v11.0``
   - sets up directory structure then copies skeleton files into ``/opt/invenio``
   - upgrades ``pip`` and installs ``pipenv``
   - installs dependencies declared in Pipfile.  The first time you run this there is no ``Pipfile.lock`` present and so pipenv first has to store all the package hashes, which takes serveral minutes.  As long as no package dependencies change, keeping this lock file in place allows pipenv to skip this step during future builds.  Therefore, after the first build copy ``Pipfile.lock`` out of the container into ``ae_datastore_lxc/app/mount/skeleton``
   - copies the config file, as well as templates, etc. to the instance folder
   - calls webpack to build static assets from the ``.js`` objects found in packages (see TO DO, this step takes a while)
   - uninstalls pipenv

**Note** inside the container, the environment variables ``RABBIT_PASSWD`` and ``OPENSEARCH_AEDATASTORE_PASSWD`` must be set (in the command above, these are sourced from a secrets file). Additionally, set ``NODE_SUFFIX`` if ``linux-x64.tar.xz`` isn't appropriate.

3. Build UI and API containers
------------------------------
Create unpriviledged copies of ``ae-datastore`` container for UI and API uWSGI instance.  Docker at least implements copy-on-write for container layering.  I'm guessing Incus does the same.


*For simplicity we're currently only going to create one copy of the base container named* ``ae-datastore-app`` *, which combines the UI and API with the API's endpoints mounted under* ``/api``.  *Once we have LDAP authentication for the API then the UI and API can run as uWSGI instances in separate containers so they can be configured individually*

::
   
   (host) $: . build_ui_container.sh ae-datastore app

The build script inside the container then:
   - creates ``celery`` and ``ae-datastore`` users
   - creates ``secrets`` and adds ``celery`` and ``ae-datastore
   - creates directory structure for celery and celerybeat daemons
   - adds an entry to ``/etc/tmpfiles.d/`` so that the volatile ``/var/run/celery`` gets recreated on reboot
   - copies celery and uWSGI unit files, etc. into ``/etc``
   - populates secrets file.  A better way is to use ``systemd``'s "credential" concept but I suspect LXC's debian bookworm image disables this
   - sets some file and directory permissions
   - enables and starts celery, celerybeat and app services

``celery`` and ``celerybeat`` services are configured via ``/etc/conf.d/celery`` and read the urls for message broker and cache services from ``/opt/invenio/var/instance/invenio.cfg``.  **Note also** that ``invenio.cfg`` reads the ``RABBIT_PASSWD`` and ``OPENSEARCH_AEDATASTORE_PASSWD`` environment variables from ``os.environ`` to configure the app.  If either of these are not present in the environment, loading the config file will raise an exception.


4. Unmount build directory
----------------------------
For example,

::

   (host) $: lxc-stop ae-datastore-app
   (host) $: sed -ir '/^lxc.mount.entry.*home\/host/d' <local lxc root>/ae-datastore-app/config
   (host) $: lxc-unpriv-start ae-datastore-app

5. Set up services
------------------

The app has a ``Click``- based command line interface (CLI) that can be invoked from inside the app container::

  (host) $: lxc-attach --clear-env ae-datastore-app \
     --keep-var RABBIT_PASSWD \
     --keep-var OPENSEARCH_AEDATASTORE_PASSWD

  (container) $: export INVENIO_INSTANCE_PATH=/opt/invenio/var/instance
  (container) $: /opt/invenio/src/.venv/bin/ae-datastore --help

or::
  
  (container) $: export INVENIO_INSTANCE_PATH=/opt/invenio/var/instance
  (container) $: . /opt/invenio/src/.venv/bin/activate
  (container) $: ae-datastore --help

**Again, note** that ``RABBIT_PASSWD`` and ``OPENSEARCH_AEDATASTORE_PASSWD`` need to be in the environment when running invoking the CLI.
  

The environment variable ``INVENIO_INSTANCE_PATH`` tells the app where to find the config files as well as static files, assets, etc..  It must be set to ``/opt/invenio/var/instance`` every time the app is loaded - either as a uWSGI instance (handled by systemd) or when the CLI is invoked.  It also has to be set when launching the celery workers (this is again handled by systemd). If not set then the app falls back to an incorrect default.  This causes strange errors.

There's a utility script inside the container to set up and tear down the services.  The tear down part is **extremely dangerous** and will be removed in production.  To initialise the search indices, database, etc.::

  (container) $: export INVENIO_INSTANCE_PATH=/opt/invenio/var/instance
  (container) $: source /opt/invenio/scripts/setup_services.sh
  (container) $: _cleanup
  (container) $: setup

*I don't understand how hostname resolution works inside containers.  Sometimes names are resolved via* ``/etc/hosts`` *on the host, sometimes they're not.  It's a mystery.  Therefore, before running the above ...* ::

  (container) $: echo "192.168.1.179"$'\t'"raspberryPi" | tee -a /etc/hosts
  ..., etc.

If there is no database named ``ae-data`` then the db client will emit an error message - just ignore it.  The final step currently adds demo data to the app, but we can easily disable this.

Depending on the number of celery worker nodes, it takes a few minutes for the initial task queue to clear.  The app can behave oddly during this time.

The app should now take requests via e.g., ``http://ui:5000``.  **Note, all security features have been disabled, so e.g., passwords are over the network in the clear.**

Finally, when deploying this elsewhere, you will probably need to set the following config variables in ``/opt/invenio/var/instance/invenio.cfg``

- ``APP_ALLOWED_HOSTS``
- ``SITE_UI_URL``
- ``SITE_API_URL``


   
