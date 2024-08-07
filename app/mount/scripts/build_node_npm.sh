#!/bin/bash

set -eux

# switch location to /tmp once all kinks ironed out.
# Oftentimes find downloads gone on container reboot, which is fine when it doesn't take 3mins
#   to download

NODE=${NODE_PACKAGE}"."${NODE_SUFF}

cd /home && \
curl ${NODE_URL_PATH}"/"${NODE} --output ${NODE} && \
curl ${NODE_URL_PATH}/"SHASUMS256.txt" --output "SHASUMS256.txt" && \

_SHA256SUM=`grep -F "${NODE}" SHASUMS256.txt | cut -f 1 -d ' '` && \
test -n "`sha256sum ${NODE} | grep -F "${_SHA256SUM}"`" && \

tar -xvf ${NODE} && \

cp --recursive ${NODE_PACKAGE}/bin/* /usr/local/bin && \
cp --recursive ${NODE_PACKAGE}/lib/* /usr/local/lib  && \
cp --recursive ${NODE_PACKAGE}/include/* /usr/local/include && \
cp --recursive ${NODE_PACKAGE}/share/* /usr/local/share
























