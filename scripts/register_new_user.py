import os

from invenio_accounts.models import User, SessionActivity, LoginInformation
from invenio_app.factory import create_app
import requests
import redis
from bs4 import BeautifulSoup

'''
os.environ['ACCOUNTS_SESSION_REDIS_URL'] = "redis://"+cache+":6379/1"
BROKER_URL="amqp://guest:guest@mq:5672/"
CACHE_REDIS_URL="redis://cache:6379/0"
CACHE_TYPE="redis"
CELERY_BROKER_URL="amqp://guest:guest@mq:5672/"
CELERY_RESULT_BACKEND="redis://cache:6379/2"
SEARCH_HOSTS=['search:9200']
SECRET_KEY="CHANGE_ME"
SQLALCHEMY_DATABASE_URI=postgresql+psycopg2://standard:standard@db/standard
WSGI_PROXIES=2
RATELIMIT_STORAGE_URL=redis://cache:6379/3


r = requests.get('https://localhost:5000/signup/', verify=False)

session = r.cookies['session']
soup = BeautifulSoup(r.text, "html.parser")
csrf_token = soup.body.find('input', {'name':'csrf_token'})['value']

print('session: {}\ncsrf_token: {}\n'.format(session, csrf_token))

headers = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0',
           'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
           'Accept-Language': 'en-GB,en;q=0.5',
           'Accept-Encoding': 'gzip, deflate, br',
           'Referer': 'https://localhost:5000/signup/',
           'Content-Type': 'application/x-www-form-urlencoded',
           'Origin': 'https://localhost:5000',
           'Connection': 'keep-alive',
           'Cookie': 'session=' + session,
           'Upgrade-Insecure-Requests': '1',
           'Sec-Fetch-Dest': 'document',
           'Sec-Fetch-Mode': 'navigate',
           'Sec-Fetch-Site': 'same-origin',
           'Sec-Fetch-User': '?1'}

data = {'next': '',
        'csrf_token': csrf_token,
        'profile.username': 'alice3',
        'profile.full_name': 'Zigmundo',
        'profile.affiliations': 'Mars',
        'email': 'alice3@example.com',
        'password': 'monkey',
        'password_confirm': 'monkey'}

r = requests.post('https://localhost:5000/signup/', headers=headers, data=data, verify=False)
print(r.status_code)

'''
app = create_app()
r = redis.StrictRedis.from_url(app.config['ACCOUNTS_SESSION_REDIS_URL'])

with app.app_context():
    user = User.query.filter_by(username='alice3').one_or_none()
    sessions = SessionActivity.query_by_user(user.id).all()

    kvsession = r.get(sessions[0].sid_s)

print(user)
print(sessions)
print(kvsession)







