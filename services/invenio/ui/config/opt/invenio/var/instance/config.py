ACCOUNTS_SESSION_REDIS_URL = "redis://10.0.3.80:6379/1"
BROKER_URL = "amqp://invenio-app:generate_me_instead@10.0.3.176:5672/vh1"
CACHE_REDIS_URL = "redis://10.0.3.80:6379/0"
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
ALLOWED_HOSTS = ['10.0.3.27:5000']

WSGI1_PROXIES = 2

