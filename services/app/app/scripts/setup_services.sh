##
# cli.services.setup(CONFIG, force=True, no_demo_data=False, stop_services=False, services=True)
# 
# commands = ServicesCommands(CONFIG)
# steps = commands.setup(force=True, no_demo_data=False, stop_services=False, services=True)
#export INVENIO_INSTANCE_PATH="/opt/invenio/var/instance"

#
# self.ensure_containers_running()
# self._cleanup() --- because force

# ServicesCommands._cleanup(self)
CMD="/opt/invenio/src/.venv/bin/ae-datastore"
_cleanup()
{
    # Flush redis
    ${CMD} shell --no-term-title -c \
	   'import redis; redis.StrictRedis.from_url(app.config["CACHE_REDIS_URL"]).flushall(); \
	   	    	 print("Cache cleared")'

    # Drop db
    ${CMD} db destroy --yes-i-know

    # Drop search indexes
    ${CMD} index destroy --force --yes-i-know

    # Purge queues
    ${CMD} index queue init purge
}

#ServicesCommands._setup(self)
_setup()
{
    # Check service status
    # self.services_expected_status(expected=False)

    # Create db
    ${CMD} db init create

    # Create default local file location
    # ! Currently in <instance_path/data> but we want an external mount
    ${CMD} files location create --default default-location ${INVENIO_INSTANCE_PATH}/data

    # Create admin role
    ${CMD} roles create admin

    # Give admin role super-user access
    ${CMD} access allow superuser-access role admin

    # Initialise search indexes
    ${CMD} index init

    # Create custom fields & communities for records (for RDM v10.0 and above - that's us)
    ${CMD} rdm-records custom-fields init
    ${CMD} communities custom-fields init

    # Create RDM fixtures (for RDM v11.0 and above - that's also us)
    ${CMD} rdm fixtures

    # Translations
    # There aren't any, so skipping - however, for future reference, see
    #   invenio_cli.commands.translations.TranslationsCommands
}

fixtures()
{
    # Set up required fixtures
    ${CMD} rdm-records fixtures
}

demo()
{
    ${CMD} rdm-records demo
}

setup()
{
    _setup
    fixtures
    demo
}


#flask --app invenio_app.wsgi_ui:application run --debug --host 0.0.0.0 --port 5000
#flask --app invenio_app.wsgi_rest:application run --debug --host 0.0.0.0 --port 5001
