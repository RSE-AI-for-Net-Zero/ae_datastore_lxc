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

2. Build service containers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Build containers for the  :ref:`OpenSearch data node <opensearch_ref>`, :ref:`RabbitMQ message broker <rabbitmq_ref>`, :ref:`PostgreSQL node <postgresql_ref>` and :ref:`Redis server <redis_ref>`

3. Build base app container
^^^^^^^^^^^^^^^^^^^^^^^^^^^


4. Build uWSGI containers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

5. Set up trusted(s) host for PostgreSQL
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

6. Initialise services
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   





	 
   

   

   

