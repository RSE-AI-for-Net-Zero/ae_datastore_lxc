#!/bin/bash

pipenv run flask --app factory:app run --debug --cert docker/nginx/test.crt --key docker/nginx/test.key --extra-files invenio.cfg
