=======================
Local config
=======================

::

   DUMMY = lambda : type('Dummy', (), {})() #I aim to cause problems! Set these elsewhere!

   REDIS_HOST = '10.0.3.80'
   REDIS_PORT = '6379'
   REDIS_URL = 'redis://' + REDIS_HOST + ':' + REDIS_PORT

   RABBITMQ_HOST = '10.0.3.176'
   RABBITMQ_PORT = '5672'
   RABBITMQ_USR = 'invenio-app'
   RABBITMQ_PASSWD = DUMMY
   RABBITMQ_VIRTHOST = 'vh1'

   ACCOUNTS_SESSION_REDIS_URL = REDIS_URL + '/1'
   BROKER_URL = 'amqp://' + RABBITMQ_USR + ':' RABBITMQ_PASSWD + '@' + RABBITMQ_HOST + \
   
   CACHE_REDIS_URL
   CACHE_TYPE = "redis"

   SEARCH_INDEX_PREFIX = "ae-datastore-"
   
   CELERY_BROKER_URL = INVENIO_BROKER_URL = BROKER_URL
   IIIF_CACHE_REDIS_URL = CACHE_REDIS_URL

   CELERY_RESULT_BACKEND = "redis://10.0.3.80:6379/2"
   RATELIMIT_STORAGE_URL = "redis://10.0.3.80:6379/3"   


   SEARCH_HOSTS = [{'host': '192.168.0.101', 'port': 9200}]
   SEARCH_CLIENT_CONFIG = {'use_ssl': True, 'verify_certs': False, 'http_auth': ('invenio_usr', 'cest_moi_666')}

   SECRET_KEY = "CHANGE_ME"

   SQLALCHEMY_DATABASE_URI = "postgresql://postgres:postgres@10.0.3.65/ae-datastore"

   WSGI1_PROXIES = 2
