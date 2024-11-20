Cookbook
--------

Find view function
^^^^^^^^^^^^^^^^^^

::

   ae-datastore routes

::

   python
   >>> from invenio_factory_patch.factory import create_app
   >>> app = create_app()
   >>> fn = app.view_functions['invenio_app_rdm_records.deposit_create']
   >>> fn.__module__

