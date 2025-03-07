.. _opensearch_ref:

OpenSearch
--------------------

Security configuration:


Configuration files, kept under version control, are found in ``opensearch/mount/config/.../``.  These will set an initial configuration.  To effect changes to these after initialisation, see ...



Updating configuration


Edit the files in ``opensearch/mount/config/.../``, then run

::

   systemd-run --user --scope -p "Delegate=yes" -- \
   lxc-attach --clear-env -n opensearch_d1_debian_bookworm_arm64 -- \
   /home/host/scripts/reconfigure_security.sh


This copies the config files to the appropriate location inside the container's ``/etc`` directory, sets their permissions, runs OpenSearch's `securityadmin.sh` script then restarts the server.

Configuration of a live cluster can also be done via the REST API using admin credentials.


Some common API commands:


e.g., with `curl`

::
   
  curl -X POST -k -u 'invenio_usr:password_1234' \
  https://raspberryPi:9200/cats/_doc \
  -H "Content-type: application/json" \
  -d '{"name": "Snowy", "Favourite toy": "Ball of wool"}'

e.g., with Python's `requests`

  


Create an index:

See `docs <https://opensearch.org/docs/2.15/api-reference/index-apis/create-index/>`_

::
   
  PUT <index-name>


Index a document


See `docs2 <https://opensearch.org/docs/2.15/api-reference/document-apis/index-document/>`_

Index (or update) a document with specific id::

  PUT <index-name>/_doc/<id> {...}

Auto-generate id::

  POST <index-name>/_doc/ {...}



Build rdm-opensearch-d*
-----------------------

::

   apt-get update && apt-get -y install git openssl

   mkdir -p /var/opensearch/data/ /var/log/opensearch/

   cd /tmp
   git clone https://github.com/RSE-AI-for-Net-Zero/ae_datastore_lxc.git
   cd ae_datastore_lxc
   git checkout <branch>
   mv services/opensearch/data-node/* /root/host/

Dev SSL Certs (do we really need to do this?)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
::

   SSL_PATH="/root/host/ssl"
   mkdir -p ${SSL_PATH}/{certs,keys}

   cd root/host

Create self-signed root cert::

  openssl genrsa -out $SSL_PATH/keys/root-ca-key.pem 2048
  
  openssl req -new -x509 -sha256 -key $SSL_PATH/keys/root-ca-key.pem \
  -subj "/C=UK/ST=ENGLAND/L=LONDON/O=IMPERIAL/OU=AERONAUTICS/CN=ROOT" \
  -out $SSL_PATH/certs/root-ca.pem -days 730

Create admin cert::

  openssl genrsa -out admin-key-temp.pem 2048

  openssl pkcs8 -inform PEM -outform PEM \
  -in admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out $SSL_PATH/keys/admin-key.pem

  openssl req -new -key $SSL_PATH/keys/admin-key.pem \
  -subj "/C=UK/ST=ENGLAND/L=LONDON/O=IMPERIAL/OU=AERONAUTICS/CN=A" -out admin.csr

  openssl x509 -req -in admin.csr -CA $SSL_PATH/certs/root-ca.pem \
  -CAkey $SSL_PATH/keys/root-ca-key.pem -CAcreateserial -sha256 -out $SSL_PATH/certs/admin.pem \
  -days 730


Create node cert::

  openssl genrsa -out node1-key-temp.pem 2048

  openssl pkcs8 -inform PEM -outform PEM -in node1-key-temp.pem \
  -topk8 -nocrypt -v1 PBE-SHA1-3DES -out $SSL_PATH/keys/node1-key.pem

  openssl req -new -key $SSL_PATH/keys/node1-key.pem \
  -subj "/C=UK/ST=ENGLAND/L=LONDON/O=IMPERIAL/OU=AERONAUTICS/CN=node1.dns.a-record" \
  -out node1.csr

  echo 'subjectAltName=DNS:node1.dns.a-record' > node1.ext

  openssl x509 -req -in node1.csr -CA $SSL_PATH/certs/root-ca.pem \
  -CAkey $SSL_PATH/keys/root-ca-key.pem -CAcreateserial \
  -sha256 -out $SSL_PATH/certs/node1.pem -days 730 -extfile node1.ext

Clean up::

  rm admin-key-temp.pem admin.csr node1-key-temp.pem node1.csr \
  node1.ext root-ca.srl


::

   OPENSEARCH_VERSION='2.15.0'
   GPG_SIGNATURE='c5b7 4989 65ef d1c2 924b a9d5 39d3 1987 9310 d3fc'



How to change passwords
-----------------------



  

  
  


