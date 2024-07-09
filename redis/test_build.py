import redis

r = redis.Redis(host='10.0.3.188', port=6379)
r.ping()
