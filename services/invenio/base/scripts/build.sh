#!/bin/bash

set -ex

NODE_SUFFIX=$1

apt-get update && apt-get install -y build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl git libcairo2 \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
			  
# /opt/invenio/var/data has already been created when setting up the bind mount
mkdir -p /opt/invenio/src

# Install python3.9
export PYENV_ROOT="/opt/pyenv"
curl https://pyenv.run --output /tmp/pyenv.run
source /tmp/pyenv.run

echo "export PYENV_ROOT=${PYENV_ROOT}" >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="${PYENV_ROOT}/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc

echo "export PYENV_ROOT=${PYENV_ROOT}" >> ~/.profile
echo 'command -v pyenv >/dev/null || export PATH="${PYENV_ROOT}/bin:$PATH"' >> ~/.profile
echo 'eval "$(pyenv init -)"' >> ~/.profile

set +x
source /root/.profile > /dev/null
set -x

pyenv install 3.9

#Set global python version
pyenv global 3.9



# Install nodejs & npm
NODE_VER='v20.9.0'

NODE_DIR="https://nodejs.org/download/release/"${NODE_VER}"/"
NODE_BASE="node-"${NODE_VER}"-"${NODE_SUFFIX}
cd /tmp &&
    curl ${NODE_DIR}${NODE_BASE} --output ${NODE_BASE} &&
    curl ${NODE_DIR}/"SHASUMS256.txt" --output "SHASUMS256.txt" && \
    _SHA256SUM=`grep -F "${NODE_BASE}" SHASUMS256.txt | cut -f 1 -d ' '` && \
    test -n "`sha256sum ${NODE_BASE} | grep -F "${_SHA256SUM}"`" && \

    tar -xvf ${NODE_BASE} && \

    # Remove tar.xz, tar.gz, etc.
    NODE_BASE=${NODE_BASE%.*} && \
    NODE_BASE=${NODE_BASE%.*} && \
	

cp --recursive ${NODE_BASE}/bin/* /usr/local/bin && \
cp --recursive ${NODE_BASE}/lib/* /usr/local/lib  && \
cp --recursive ${NODE_BASE}/include/* /usr/local/include && \
cp --recursive ${NODE_BASE}/share/* /usr/local/share


WORKING_DIR=/opt/invenio
WORKING_DIR_SRC=${WORKING_DIR}/src
export INVENIO_INSTANCE_PATH=${WORKING_DIR}/var/instance

mkdir -p ${WORKING_DIR_SRC} \
      ${INVENIO_INSTANCE_PATH}/archive \
      ${INVENIO_INSTANCE_PATH}/static \
      ${INVENIO_INSTANCE_PATH}/assets
      

mkdir -p /etc/conf.d

cp --recursive /root/host/skeleton/* ${WORKING_DIR_SRC}



# We're now mimicking the steps executed by invenio-cli install --no-dev --production.
# However, in spite of --production --no-dev options, invenio-cli still seems to symlink templates and
# app_data directories into instance folder.  This seems dodgy in production.  Intention is to limit
# priviledges of process running uwsgi to access what is in the <instance> directory.

# 1. - call cli.install.(cli_config, pre=False, dev=False, production=True)
# 1.1 - calls commands = InstallCommand(cli_config)
# 1.2 - calls steps = commands.install(pre=False, dev=False, flask_env='production')
# 1.3 - calls run_steps(steps, ...)

# 1.2.1 - install_py_dependencies(False, False)
# 1.2.1.1 - PackagesCommands.is_locked ? Yes, Pipfile.lock shipped in repo
# 1.2.1.2 - Packages commands install locked deps(False, False)
# ---> CommandStep(["pipenv", "sync"]

pip install --upgrade pip --root-user-action ignore
pip install pipenv --root-user-action ignore

# Ssh!
export PIPENV_VERBOSITY="-1"
# Tell pipenv to create venv in the current directory
export PIPENV_VENV_IN_PROJECT=1
export PIPENV_PYTHON=${PYENV_ROOT}/shims/python

cd ${WORKING_DIR_SRC} && \
    if ! test -f Pipfile.lock; then
	pipenv lock
    fi && \

pipenv sync


# 1.2.2 - update_instance_path - only affects config - pass
# 1.2.3 - copy invenio.cfg
cp invenio*.cfg ${INVENIO_INSTANCE_PATH}

# 1.2.4 - copy templates/
cp --recursive templates/ ${INVENIO_INSTANCE_PATH}/templates

# 1.2.5 - copy templates/ app_data/
cp --recursive app_data/ ${INVENIO_INSTANCE_PATH}/app_data

# 1.2.6 - update_statics_and_assets(force=True, flask_env='production', log_file=None)
pipenv run ae-datastore collect --verbose
pipenv run ae-datastore webpack clean create
pipenv run ae-datastore webpack install
cp --recursive static/* ${INVENIO_INSTANCE_PATH}/static
cp --recursive assets/* ${INVENIO_INSTANCE_PATH}/assets

## invenio-cli then goes and symlinks ./assets/* to their corresponding files in <instance_path/assets
##  Why?  Not sure yet.
pipenv run ae-datastore webpack build

# Remove pipenv
pip uninstall -y pipenv --root-user-action ignore

# Get base build stuff out of the way
mv root/host/skeleton/ root/host/scripts/ root/host/base/




