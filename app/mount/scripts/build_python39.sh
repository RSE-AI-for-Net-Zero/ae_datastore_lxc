#!/bin/bash

set -ux

apt-get update
apt-get install -y --no-install-recommends ca-certificates git curl \
	build-essential libssl-dev zlib1g-dev \
	libbz2-dev libreadline-dev libsqlite3-dev curl git \
	libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

cd /tmp
git clone https://github.com/python/cpython.git
cd /tmp/cpython
git checkout v3.9.19

./configure --enable-optimizations --with-lto
make && make install

ln -sfn /usr/local/bin/python3 /usr/local/bin/python
pip3 install --upgrade pip pipenv wheel

if test -n "`python --version | grep -F '3.9'`";  then
    echo `python --version` "installed!"
else
    echo "nope"
    exit 1
fi

rm -rf /tmp/cpython






















