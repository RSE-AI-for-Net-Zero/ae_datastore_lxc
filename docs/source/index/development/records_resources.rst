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

    instance.record_cls = class Name(Record):
    				model_cls = NameMetadata
				schema = ...
				index = ...
				pid = ...
				dumper = ...
				relations = \
				  invenio_vocabularies.contrib.names.name_relations

- ``NameResourceConfig`` and ``NameResource`` (in ``create_resource_class()``)::

    instance.resource_config_cls =\
    
    	class NameResourceConfig(RecordResourceConfig):
    		blueprint_name = "name"
		url_prefix = "/names"

    instance.resource_cls =\
    
    	class NameResource(RecordResource):
    		pass

- ``NameServiceConfig``, ``NameService`` (in ``create_service_class()``)::

    To do

``Record`` defined in ``invenio_records_resources.records.api``

``NameResource`` inherits from ``RecordResource``, which inherits from ``flask_resources.Resource``, which is very interesting.

Look at ``invenio_vocabularies.ext`` For


