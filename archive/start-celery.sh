#!/bin/bash

pipenv run celery --app invenio_app.celery worker --beat --events --loglevel INFO
