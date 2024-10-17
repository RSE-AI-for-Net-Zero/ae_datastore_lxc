What does this API call do?
===========================


.. image:: /images/new_upload.png
	   
Open the browser's development tools window (e.g., with Firefox Ctrl-Shift-I) and open the Network tab.

.. image:: /images/add_creator.png

What we see depends on whether API is deployed as a separate uWSGI instance.  In case that the API is embedded within the UI instance, with its routes mounted beneath ``/api``, as we begin to type into the first form field, we see the page attempting the following API call::
  
  GET https://127.0.0.1:5000/api/names?size=20&suggest=amb

Find the view function
----------------------

The Flask app CLI provides a ``routes`` command that fetches up a list of routes and their matching endpoints.  
	   
::
   
   (container) $: . /opt/invenio/src/.venv/bin/activate

   (src) $: flask --app invenio_factory_patch.factory:create_api routes  \
   |  grep -F 'names'

   ...

   name.create			POST	/names
   name.delete                  DELETE	/names/<path:pid_value>
   name.name_resolve_by_id      GET     /names/<pid_type>/<pid_value>
   name.read                    GET     /names/<path:pid_value>
   name.search                  GET     /names
   name.update                  PUT     /names/<path:pid_value>

  
From this output we see that ``name.search`` endpoint handled the request.  To find the corresponding view function::

  (src) $: python

::
   
  >>> from invenio_factory_patch.factory import create_api
  >>> api = create_api()
  >>> view_fn = api.view_functions['name.search']
  >>> view_fn.__module__

  'flask_resources.resources'

So, what is flask-resources?  Firstly, what version do we have?::

  (src) $: pip list | grep -E "(f|F)lask"

  ...
  Flask-OAuthlib              0.9.6
  Flask-Principal             0.4.0
  flask-resources             0.9.1
  Flask-RESTful               0.3.10
  Flask-Security-Invenio      3.1.4
  ...

From the docs, it provides blueprint factories that can be parameterised via config, e.g., ``names``.  Let's now figure out where this blueprint is created::

  (src) $: cd /opt/invenio/src/.venv/lib/.../site-packages
  (src) $: grep -rlFZ 'flask_resources' * \
           | grep -vzE "(__pycache__)|(flask_resources)|(dist-info/)" \
	   | xargs -0 grep -nl 'names'

        ...
	invenio_vocabularies/contrib/names/resources.py
	...


The class ``NamesResource`` is defined in the package ``invenio_vocabularies`` and inherits from ``.names.record_type`` - a product of ``RecordTypeFactory`` defined in ``invenio-records-resources``.

::

   record_type = RecordTypeFactory(
   	"Name",
	# Data layer
	pid_field_kwargs={
		"create": False,
		"provider": PIDProviderFactory.create(
			pid_type="names", base_cls=RecordIdProviderV2
		),
		"context_cls": BaseVocabularyPIDFieldContext,
	},
	schema_version="1.0.0",
	schema_path="local://names/name-v1.0.0.json",
	record_relations=name_relations,
	record_dumper=SearchDumper(
		extensions=[
			RelationDumperExt("relations"),
			IndexedAtDumperExt(),
		]
	),
	# Service layer
	service_id="names",
	service_schema=NameSchema,
	search_options=NamesSearchOptions,
	service_components=service_components,
	permission_policy_cls=PermissionPolicy,
	# Resource layer
	endpoint_route="/names",
	)


``RecordTypeFactory``
-----------------------------------------------

``create_record_type()`` dynamically creates the following classes with equivalent static definitions

- ``NameMetadata`` (``create_metadata_model()``)::

    instance.model_cls = class NameMetadata(db.Model, RecordMetadataBase):
			    	__tablename__ = name_metadata

- ``Name`` (in ``self.create_record_class()``)::

    instance.record_cls = class Name(invenio_records_resources.records.api.Record):
    				model_cls = NameMetadata
				schema = ...
				index = ...
				pid = ...
				dumper = ...
				relations = \
				  invenio_vocabularies.contrib.names.name_relations

- ``NameResourceConfig`` and ``NameResource`` (in ``create_resource_class()``)::

    instance.resource_config_cls =\
    
    	class NameResourceConfig(invenio_records_resources.RecordResourceConfig):
    		blueprint_name = "name"
		url_prefix = "/names"
    
    class NameResource(invenio_records_resources.RecordResource):
    	pass

- ``NameServiceConfig``, ``NameService`` (in ``create_service_class()``)::

    To do


``NameResource`` inherits from ``RecordResource``, which inherits from ``flask_resources.Resource``, which is very interesting.

Look at ``invenio_vocabularies.ext`` For

- ``Affliations``
- ``Awards``
- ``Funders``
- ``Names``
- ``Subjects``

there correspond the classes

- ``*Resource`` ( |right arrow| ``RecordResource``)
- ``*ResourceConfig`` (|right arrow| ``RecordResourceConfig``)
- ``*Service`` (|right arrow| ``RecordService``)
- ``*ServiceConfig`` (|right arrow| ``RecordServiceConfig``)


and ``invenio_vocabularies.views``.

.. |right arrow| unicode:: U+2192
    	
  
	



	








