#!/bin/bash

set -eux

cd /tmp

curl https://nodejs.org/download/release/v16.9.1/node-v16.9.1-linux-x64.tar.gz --output node-v16.9.1-linux-x64.tar.gz

tar -xvf node-v16.9.1-linux-x64.tar.gz

cp --recursive node-v16.9.1-linux-x64/bin/* /usr/local/bin
cp --recursive node-v16.9.1-linux-x64/lib/* /usr/local/lib
cp --recursive node-v16.9.1-linux-x64/include/* /usr/local/include
cp --recursive node-v16.9.1-linux-x64/share/* /usr/local/share

if test -n "`node --version | grep -F '16.9.1'`" -a "`npm --version | grep -F '7.21.1'`"; then
    echo "node " `node --version` "and npm " `npm --version` "installed!"
else
    echo "nope"
    exit 1
fi

rm -rf /tmp/node-v16.9.1-linux-x64.tar.gz /tmp/node-v16.9.1-linux-x64.tar.gz






















