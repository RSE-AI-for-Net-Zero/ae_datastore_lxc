import os
import sys
import pika

ip_address = str(sys.argv[1])

def main(ip_address):
    '''
    https://www.rabbitmq.com/tutorials/tutorial-one-python
    '''
    url = "amqp://invenio-app:generate_me_instead@" + ip_address + "/vh1"
    connection = pika.BlockingConnection(pika.URLParameters(url))
    channel = connection.channel()
    channel.queue_declare(queue='hello')
    channel.basic_publish(exchange='',
                      routing_key='hello',
                      body='Hello World!')
    print(" [x] Sent 'Hello World!'")
    connection.close()


if __name__ == '__main__':
    main(ip_address)

