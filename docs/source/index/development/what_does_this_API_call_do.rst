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

From the docs, it provides blueprint factories that can be parameterised via config, e.g., ``names``.  Let's now figure out where this blueprint is created.  We'll search ``site-packages`` for modules that import from ``flask_resources``, filter out the rubbish then search what remains for occurrences of "``names``"::

  (src) $: cd /opt/invenio/src/.venv/lib/.../site-packages
  (src) $: grep -rlFZ 'flask_resources' * \
           | grep -vzE "(__pycache__)|(flask_resources)|(dist-info/)" \
	   | xargs -0 grep -nl 'names'


	invenio_app_rdm/config.py
	invenio_vocabularies/contrib/names/resources.py


``invenio_vocabularies/contrib/names/resources.py`` defines two classes: ``NamesResource`` and ``NamesResourceConfig`` that each inherit from classes created by the factory function ``RecordTypeFactory`` defined in ``invenio_records_resources.factories.factory``.

``NamesResource`` inherits directly from ``NameResource`` - one of the classes created using ``RecordTypeFactory`` - which in turn is::

  class NameResource(RecordResource):
  	pass

  ...

  class RecordResource(ErrorHandlersMixin, Resource):
  	...

``Resource`` is defined in ``flask-resources``




Looking at ``invenio-vocabularies``, for each of

- ``Affliations``
- ``Awards``
- ``Funders``
- ``Names``
- ``Subjects``

there correspond four classes

- ``*Resource``
- ``*ResourceConfig``
- ``*Service``
- ``*ServiceConfig``

``*Resource`` and ``*ResourceConfig``
-------------------------------------

To do

``*Service`` and ``*ServiceConfig``
-------------------------------------

To do

.. image:: /images/vocab_classes.drawio.png

.. |right arrow| unicode:: U+2192

