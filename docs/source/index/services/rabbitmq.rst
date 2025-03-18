.. _rabbitmq_ref:

build rdm-rabbitmq
------------------

::
   
   apt-get update && apt-get -y install git
   mkdir -p /root/host
   cd /tmp
   git clone https://github.com/RSE-AI-for-Net-Zero/ae_datastore_lxc.git
   cd ae_datastore_lxc
   git checkout <branch>
   mv services/rabbitmq/* /root/host/
   cd /
   RABBIT_PASSWD="..."
   ./root/host/scripts/build.sh ${RABBIT_PASSWD}

Creates user `ae-datastore` and a virtual host `1`.  To change the password::

  NEW_PASSWD="..."
  rabbitmqctl change_password ae-datastore ${NEW_PASSWD}
   
