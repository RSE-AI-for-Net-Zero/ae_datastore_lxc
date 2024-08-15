##
# cli.services.setup(CONFIG, force=True, no_demo_data=False, stop_services=False, services=True)
# 
# commands = ServicesCommands(CONFIG)
# steps = commands.setup(force=True, no_demo_data=False, stop_services=False, services=True)
#
# self.ensure_containers_running()
# self._cleanup() --- because force

# ServicesCommands._cleanup(self)
_cleanup()
{
    # Flush redis
    invenio shell --no-term-title -c \
	    'import redis; redis.StrictRedis.from_url(app.config["CACHE_REDIS_URL"]).flushall(); \
	    print("Cache cleared")'

    # Drop db
    invenio db destroy --yes-i-know

    # Drop search indexes
    invenio index destroy --force --yes-i-know

    # Purge queues
    invenio index queue init purge
}

#ServicesCommands._setup(self)
_setup()
{
    # Check service status
    # self.services_expected_status(expected=False)

    # Create db
    invenio db init create

    # Create default local file location
    # ! Currently in <instance_path/data> but we want an external mount
    invenio files location create --default default-location ${INVENIO_INSTANCE_PATH}/data

    # Create admin role
    invenio roles create admin

    # Give admin role super-user access
    invenio access allow superuser-access role admin

    # Initialise search indexes
    invenio index init

    # Create custom fields & communities for records (for RDM v10.0 and above - that's us)
    invenio rdm-records custom-fields init
    invenio communities custom-fields init

    # Create RDM fixtures (for RDM v11.0 and above - that's also us)
    invenio rdm fixtures

    # Translations
    # There aren't any, so skipping - however, for future reference, see
    #   invenio_cli.commands.translations.TranslationsCommands
}

fixtures()
{
    # Set up required fixtures
    invenio rdm-records fixtures
}

demo()
{
    invenio rdm-records demo
}

setup()
{
    _cleanup
    _setup
    fixtures
    demo
}


