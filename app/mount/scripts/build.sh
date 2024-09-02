#!/bin/bash

apt-get update && apt-get install -y build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl git \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# /opt/invenio/var/data has already been created when setting up the bind mount
mkdir -p /opt/invenio/src

# Install python3.9
export PYENV_ROOT="/root/.pyenv"
curl https://pyenv.run | bash

[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

pyenv install 3.9
pyenv global 3.9

# Install nodejs & npm
NODE_VER='v20.9.0'
NODE_SUFF=${NODE_SUFFIX:-"linux-x64.tar.xz"}

NODE_DIR="https://nodejs.org/download/release/"${NODE_VER}"/"
NODE_BASE="node-"${NODE_VER}"-"${NODE_SUFF}
cd /tmp &&
    curl ${NODE_DIR}${NODE_BASE} --output ${NODE_BASE} &&
    curl ${NODE_DI}/"SHASUMS256.txt" --output "SHASUMS256.txt" && \
    _SHA256SUM=`grep -F "${NODE_BASE}" SHASUMS256.txt | cut -f 1 -d ' '` && \
    test -n "`sha256sum ${NODE_BASE} | grep -F "${_SHA256SUM}"`" && \

    tar -xvf ${NODE_BASE}

# Remove tar.xz, tar.gz, etc.
NODE_BASE=${NODE_BASE%.*}
NODE_BASE=${NODE_BASE%.*}













