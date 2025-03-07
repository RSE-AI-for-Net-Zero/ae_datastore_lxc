.. _basecontainer_ref:

Common base container build
---------------------------

Whenever the command line ``ae-datastore`` is invoked, make sure that the environment variable ``INVENIO_INSTANCE_PATH`` is set to `/opt/invenio/var/instance`.  This is relevant, e.g., when resuming the build script midway through.

These steps are common to the builds of `rdm-invenio-ui` and `rdm-invenio-api`.  As root, inside a Debian Bookworm container::

  apt-get update && apt-get -y install git
  mkdir -p /root/host /opt/invenio/var/instance/{data,log}
  cd /tmp
  git clone https://github.com/RSE-AI-for-Net-Zero/ae_datastore_lxc.git
  cd ae_datastore_lxc
  git checkout <branch>
  mv services/invenio/* /root/host
  cd /
  mv root/host/base/* root/host
  ./root/host/scripts/build.sh "linux-x64.tar.xz"


The build script
 - installs `pyenv`, `npm` & `node.js`
 - 


UI & API container builds
-------------------------

Clear up::

  mv root/host/scripts/ root/host/skeleton/ root/host/base/

Set secrets::

   RABBITMQ_PASSWD="..."
   OPENSEARCH_AEDATASTORE_USER_PASSWD="..."
   
   mv root/host/ui/* root/host/
   cd /
   
   ./root/host/scripts/build.sh ${RABBITMQ_PASSWD} ${OPENSEARCH_AEDATASTORE_USER_PASSWD}

Celery log files

::

   cat /var/log/celery/w1.log
  

