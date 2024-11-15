Deployment (Incus)
==================

Set up directories 
------------------

Create a user on host whose uid is mapped to the root user inside containers.  E.g.,

``/etc/subuid``
::
   
   leeb:100000:65536
   root:1000000:1000000000

``/etc/subgid``
::

   leeb:100000:65536
   root:1000000:1000000000

``/etc/passwd``
::

   ...
   lxc:x:100000:100000::/home/lxc:/bin/sh
   incusRoot:x:1000000:1000000::/home/incusRoot:/bin/sh

Create directories and set owner and group to new user
   
.. code::

   EXTERNAL_STORAGE_ROOT=~/.local/var/lxc
   
   mkdir -p ${EXTERNAL_STORAGE_ROOT}/{opensearch_d1,postgresql_1,ae-datastore} \
          ${EXTERNAL_STORAGE_ROOT}/opensearch_d1/{data,log} \
	  ${EXTERNAL_STORAGE_ROOT}/postgresql_1/data \
	  ${EXTERNAL_STORAGE_ROOT}/ae-datastore/{data,log} \

   sudo chown -R incusRoot:incusRoot \
          ${EXTERNAL_STORAGE_ROOT}/{opensearch_d1,postgresql_1,ae-datastore}

Run deployment script
---------------------
.. code::
   
    INCUS_CMD="sudo incus"

   ./incus/deploy.sh

A broad description of what ``deploy.sh`` does is as follows:   

1. Preparatory steps
^^^^^^^^^^^^^^^^^^^^

- Set container base image, installation prefix, command, node suffix and host directories to mount inside containers.
- Read secrets file (and request user entry if secrets file not present)
- Create set of self-signed SSL certificates

2. Builds Service containers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Build containers for the  :ref:`OpenSearch data node <opensearch_ref>`, :ref:`RabbitMQ message broker <rabbitmq_ref>`, :ref:`PostgreSQL node <postgresql_ref>` and :ref:`Redis server <redis_ref>`

3. Builds base app container
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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





	 
   

   

   

