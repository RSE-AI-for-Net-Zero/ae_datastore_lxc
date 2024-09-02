#!/bin/bash

set -eux


apt-get update && apt-get install -y haproxy python3-pip python3-dev \
			  build-essential libssl-dev libffi-dev python3-setuptools \
			  python3-venv


useradd app_usr --shell '/bin/sh' --system
mkdir -p /opt/app
cd /opt/app


source .venv/bin/activate
pip install --upgrade pip flask uwsgi wheel

openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes -subj "/C=UK/ST=England/L=Lonond/O=Examply/OU=Nothing/CN=www.example.com"
