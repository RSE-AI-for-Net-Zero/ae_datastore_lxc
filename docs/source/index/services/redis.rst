.. _redis_ref:

build rdm-redis
---------------

::

   apt-get update && apt-get -y install git
   mkdir -p /root/host
   cd /tmp
   git clone https://github.com/RSE-AI-for-Net-Zero/ae_datastore_lxc.git
   cd ae_datastore_lxc
   git checkout <branch>
   mv services/redis/* /root/host/
   cd /
   ./root/host/scripts/build.sh
   ./root/host/scripts/configure.sh
