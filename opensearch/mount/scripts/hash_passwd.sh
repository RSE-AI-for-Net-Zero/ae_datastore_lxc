#!/bin/bash

export OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk
/usr/share/opensearch/plugins/opensearch-security/tools/hash.sh -p $1 | tee hashed.psswd
