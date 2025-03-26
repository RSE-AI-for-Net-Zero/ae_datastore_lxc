------------------
Build process
------------------

Each deployment requires building the following containers based on a Debian Bookworm image.

- `rdm-redis`
- `rdm-rabbitmq`
- `rdm-opensearch-d1`  
- `rdm-postgresql-1`
- `rdm-invenio-ui`
- `rdm-invenio-api`

[!ToDo!] List external filesystem mounts.
  
1. Build `rdm-redis`
^^^^^^^^^^^^^^^^^^^^

Installs *redis-server* from Bookworm apt repo and makes minor changes to its configuration (see build scripts).  

::

   apt-get update && apt-get -y install git
   mkdir -p /root/host
   cd /tmp
   git clone https://github.com/RSE-AI-for-Net-Zero/ae_datastore_lxc.git
   cd ae_datastore_lxc
   git checkout <ref>
   mv services/redis/* /root/host/
   cd /
   ./root/host/scripts/build.sh
   ./root/host/scripts/configure.sh


2. Build `rdm-rabbitmq`
^^^^^^^^^^^^^^^^^^^^^^^

Installs *rabbitmq-server* from the package repo, then creates a virtual host, labelled `1`, a user *ae-datastore* and sets a password (to change this password later on see :ref:`rabbitmq_ref`).

Set a password::
  
  RABBIT_PASSWD=<passwd>

::
   
   apt-get update && apt-get -y install git
   mkdir -p /root/host
   cd /tmp
   git clone https://github.com/RSE-AI-for-Net-Zero/ae_datastore_lxc.git
   cd ae_datastore_lxc
   git checkout <ref>
   mv services/rabbitmq/* /root/host/
   cd /
   ./root/host/scripts/build.sh ${RABBIT_PASSWD}

3. Build `rdm-opensearch-d1`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Set up self-signed TLS certifcates**

What's the point of this given our cluster consists of a single data node?  The Opensearch docs say that `these are mandatory for node-to-node communication <https://opensearch.org/docs/2.15/security/configuration/tls/>`_.

Create a place in the container directory tree to temporarily hold the certs and keys

::

   SSL_PATH="/root/host/ssl"
   mkdir -p ${SSL_PATH}/{certs,keys}

   cd root/host

Install openssl and curl::

  apt-get update && apt-get -y install git openssl curl
   
Create a self-signed root cert (this will do for now, but when extra nodes are added would be good idea to use a properly signed certifcate)::

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


Create a node cert::

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

Install *Opensearch v2.15.0* from *https://artifacts.opensearch.org* then configure::

  mkdir -p /var/opensearch/data/ /var/log/opensearch/

  cd /tmp
  git clone https://github.com/RSE-AI-for-Net-Zero/ae_datastore_lxc.git
  cd ae_datastore_lxc
  git checkout <ref>
  mv services/opensearch/data-node/* /root/host/

Set version and (possibly unnecessarily) set gpg signature::

  OPENSEARCH_VERSION='2.15.0'
  GPG_SIGNATURE='c5b7 4989 65ef d1c2 924b a9d5 39d3 1987 9310 d3fc'

When building from package an initial superuser password is required (see :ref:`opensearch_ref` for how to change this)::

  OPENSEARCH_INITIAL_ADMIN_PASSWORD=<passwd>


We also create a user with reduced priviledges named *ae-datastore*, and set its password::

  OPENSEARCH_AEDATASTORE_PASSWD=<passwd>

Run the build and configure scripts::

  ./root/host/scripts/build.sh ${OPENSEARCH_INITIAL_ADMIN_PASSWORD} \
          ${OPENSEARCH_VERSION} ${GPG_SIGNATURE}


  ./root/host/scripts/configure.sh ${OPENSEARCH_INITIAL_ADMIN_PASSWORD} \
          ${OPENSEARCH_AEDATASTORE_PASSWD}

Did it work?::

  curl -k -u "admin:${OPENSEARCH_INITIAL_ADMIN_PASSWORD}" https://localhost:9200
  curl -k -u "ae-datastore:${OPENSEARCH_AEDATASTORE_PASSWD}" https://localhost:9200

should both respond with something that looks like::

  {
  	"name" : "data-1",
  	"cluster_name" : "aero-datastore",
	...
  }


4. Build `rdm-postgresql-1`
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Build postgresql v15.0 from apt::

  apt-get update && apt-get -y install git host
  mkdir -p /root/host /var/lib/postgres/data
  cd /tmp
  git clone https://github.com/RSE-AI-for-Net-Zero/ae_datastore_lxc.git
  cd ae_datastore_lxc
  git checkout <ref>
  mv services/postgresql/* /root/host/
  cd /
  ./root/host/scripts/build_node.sh

We then configure the server to accept unauthenticated TCP/IP requests from *rdm-invenio-ui* and *rdm-invenio-api* and to reject requests from all other hosts.  This can be done either by host name or IP address range by `adding appropriate entries <https://www.postgresql.org/docs/15/auth-pg-hba-conf.html>`_ to the ``pg_hba.conf`` ("postgres-host-based-access.conf") config file.  

Setting trusted hosts by hostname is a `little more complicated <https://www.postgresql.org/docs/15/auth-pg-hba-conf.html>`_ ...

	"Users sometimes wonder why host names are handled in this seemingly complicated way, with two name resolutions including a reverse lookup of the client's IP address. This complicates use of the feature in case the client's reverse DNS entry is not set up or yields some undesirable host name. It is done primarily for efficiency: this way, a connection attempt requires at most two resolver lookups, one reverse and one forward. If there is a resolver problem with some address, it becomes only that client's problem. A hypothetical alternative implementation that only did forward lookups would have to resolve every host name mentioned in pg_hba.conf during every connection attempt. That could be quite slow if many names are listed. And if there is a resolver problem with one of the host names, it becomes everyone's problem.

	Also, a reverse lookup is necessary to implement the suffix matching feature, because the actual client host name needs to be known in order to match it against the pattern.

	Note that this behavior is consistent with other popular implementations of host name-based access control, such as the Apache HTTP Server and TCP Wrappers."

First, use *host* to do a reverse DNS look up on *rdm-invenio-ui* and *rdm-invenio-api*'s IP addresses, e.g.,::

  host 10.48.175.*

This gives something like *rdm-invenio-ui-blue.incus* and *rdm-invenio-api-blue.incus* - this is the host name to be addded as a *trusted host* to ``pg_hba.conf``.  There's a script that does this, then restarts the server.  Before running for the first time, put it somewhere in the container's search path::

  cp /root/host/scripts/add_trusted_host.sh /usr/local/bin

Then::

  add_trusted_host.sh rdm-invenio-ui-blue.incus
  add_trusted_host.sh rdm-invenio-api-blue.incus

Once this is done, add the *rdm-invenio* containers' IPv4 and IPv6 addresses to ``/etc/hosts`` (both appear to be necessary)::

  echo """
  10.48.175.***				rdm-invenio-ui-blue.incus
  fd42:5d08:8368:96ec:216:3eff:fe88:***	rdm-invenio-ui-blue.incus

  10.48.175.***	                        rdm-invenio-api-blue.incus
  fd42:5d08:8368:96ec:216:3eff:fe88:***	rdm-invenio-api-blue.incus
  """ | tee -a /etc/hosts
  

5. Common build steps for `rdm-invenio-ui` and `rdm-invenio-api`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These steps are common to both.  First of all, for the command-line tool *ae-datastore* to be invoked correctly, the environment variable ``INVENIO_INSTANCE_PATH`` must be set to `/opt/invenio/var/instance`, otherwise on app load the instance path defaults to somewhere else and you get subtle, difficult to debug, errors.  Therefore, in each container add the following line to ``/root/.bashrc``::

  export INVENIO_INSTANCE_PATH="/opt/invenio/var/instance

then restart shell::

  exec bash

Doing this now will be helpful in case the build scripts have to be stopped and restared midway when it's easy to forget to reset ``INVENIO_INSTANCE_PATH``.

Now install the base dependencies (*pyenv*, *Python3.9*, *node.js*, *npm* & *pipenv*)::

  apt-get update && apt-get -y install git
  mkdir -p /root/host /opt/invenio/var/instance/{data,log}
  cd /tmp
  git clone https://github.com/RSE-AI-for-Net-Zero/ae_datastore_lxc.git
  cd ae_datastore_lxc
  git checkout <ref>
  mv services/invenio/* /root/host
  cd /
  mv root/host/base/* root/host
  ./root/host/scripts/build.sh "linux-x64.tar.xz"

6. Build `rdm-invenio-ui` and `rdm-invenio-ui`
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These steps are similar for each container, so we described `rdm-invenio-ui` here and make the appropriate changes for `rdm-invenio-api`.

First clear up from the previous build step::

  mv root/host/scripts/ root/host/skeleton/ root/host/base/

Set secrets::

   RABBITMQ_PASSWD="..."
   OPENSEARCH_AEDATASTORE_USER_PASSWD="..."
   SECRET_KEY="..."
   
   mv root/host/ui/* root/host/
   cd /

Run the build script::

   ./root/host/scripts/build.sh ${RABBITMQ_PASSWD} \
	${OPENSEARCH_AEDATASTORE_USER_PASSWD} \
	${SECRET_KEY}

Add the following lines to :file:`/root/.bashrc` in both containers - these export the secrets on opening a new shell so that the cmd line *ae-datastore* can be invoked::

  set -a
  source /etc/conf.d/secrets
  set +a

Make sure the following keys in `invenio.cfg` are pointing to the right URLs, e.g.,::

  LDAPCLIENT_SERVER_KWARGS = [{'host': 'ldaps://ldap0.ae.ic.ac.uk',
  				'tls': ldap3.Tls(validate=ssl.CERT_NONE)},
			      {'host': 'ldaps://ldap1.ae.ic.ac.uk',
                                'tls': ldap3.Tls(validate=ssl.CERT_NONE)}]

  SQLALCHEMY_DATABASE_URI="postgresql://postgres:*******@rdm-postgresql-1-dev/ae-data"
  
  CACHE_REDIS_URL="redis://rdm-redis-dev:6379/0"
  ACCOUNTS_SESSION_REDIS_URL="redis://rdm-redis-dev:6379/1"
  CELERY_RESULT_BACKEND="redis://rdm-redis-dev:6379/2"
  RATELIMIT_STORAGE_URL="redis://rdm-redis-dev:6379/3"
  COMMUNITIES_IDENTITIES_CACHE_REDIS_URL="redis://rdm-redis-dev:6379/4"
  IIIF_CACHE_REDIS_URL="redis://rdm-redis-dev:6379/5"

  BROKER_URL="amqp://ae-datastore:" + RABBIT_PASSWD + "@rdm-rabbitmq-dev:5672/1"
  CELERY_BROKER_URL="amqp://ae-datastore:" + RABBIT_PASSWD + "@rdm-rabbitmq-dev:5672/1"
  SEARCH_HOSTS=['rdm-opensearch-d1-dev:9200']


Make sure the following keys are also set appropriately.  I.e., either::

  SITE_UI_URL = "https://data-dev.ae.ic.ac.uk"
  SITE_API_URL = "https://data-dev.ae.ic.ac.uk/api"
  APP_ALLOWED_HOSTS = ['0.0.0.0', 'localhost', '127.0.0.1', \
    'data-dev.ae.ic.ac.uk', 'store-dev.ae.ic.ac.uk']
  LDAPCLIENT_GROUP_SEARCH_FILTERS = \
    [lambda u : f'(&(objectclass=posixGroup)(cn=acc-data-repo-dev)(memberUid={u}))']

or::

  SITE_UI_URL = "https://data.ae.ic.ac.uk"
  SITE_API_URL = "https://data.ae.ic.ac.uk/api"
  APP_ALLOWED_HOSTS = ['0.0.0.0', 'localhost', '127.0.0.1', \
    'data.ae.ic.ac.uk', 'store.ae.ic.ac.uk']
  LDAPCLIENT_GROUP_SEARCH_FILTERS = \
    [lambda u : f'(&(objectclass=posixGroup)(cn=acc-data-repo)(memberUid={u}))']


Finally, make sure directory permissions are set appropriately for *${INVENIO_INSTANCE_PATH}/data* and *${INVENIO_INSTANCE_PATH}/log/ae-datastore.app.log*::

  chown -R root:ae-datastore ${INVENIO_INSTANCE_PATH}/data ${INVENIO_INSTANCE_PATH}/log \
    ${INVENIO_INSTANCE_PATH}/log/ae-datastore.app.log

  chmod -R g+w ${INVENIO_INSTANCE_PATH}/data ${INVENIO_INSTANCE_PATH}/log \
    ${INVENIO_INSTANCE_PATH}/log/ae-datastore.app.log


Restart everything::

  systemctl restart ui.service celery.service celerybeat.service

Check the logs to see everything's happy::

  journalctl -xeu ui.service
  journalctl -xeu celerybeat.service
  cat /var/log/celery/w{1,2,3}.log


7. Initialse DB, Opensearch indices, message cache, etc.
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First, make sure secrets are loaded into environment variables::

  source /etc/conf.d/secrets

  export RABBIT_PASSWD
  export SECRET_KEY
  export OPENSEARCH_AEDATASTORE_PASSWD


Then::
   
   CMD="/opt/invenio/src/.venv/bin/ae-datastore"
   # Create db
   ${CMD} db init create

   # Create default local file location
   # ! Currently in <instance_path/data> but we want an external mount
   ${CMD} files location create --default default-location ${INVENIO_INSTANCE_PATH}/data
   
   # Create admin role
   ${CMD} roles create admin
   
   # Give admin role super-user access
   ${CMD} access allow superuser-access role admin
   
   # Initialise search indexes
   ${CMD} index init
   
   # Create custom fields & communities for records (for RDM v10.0 and above - that's us)
   ${CMD} rdm-records custom-fields init
   ${CMD} communities custom-fields init
   
   # Create RDM fixtures (for RDM v11.0 and above - that's us)
   ${CMD} rdm fixtures
   ${CMD} rdm-records fixtures


(All this as well as a **very dangerous** clean up shell function are in *setup_services.sh*).







