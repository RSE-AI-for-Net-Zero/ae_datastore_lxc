New upload
==========
::

   pipenv run ae-datastore routes | grep uploads/new
   ...
   invenio_app_rdm_records.deposit_create 	GET	/uploads/new

::

   pipenv run python

::

   >>> from invenio_factory_patch.factory import create_app
   >>> app = create_app()
   >>> f = app.view_functions['invenio_app_rdm_records.deposit_create']
   >>> f.__module__, f.__name__
   ('invenio_app_rdm.records_ui.views.deposits', 'deposit_create')

View function renders template::

  invenio_app_rdm/records/deposit.html

which contains::

  {{ webpack['invenio-app-rdm-deposit.js'] }}

``invenio_app_rdm/theme/webpack.py`` contains::

  "invenio-app-rdm-deposit": "./js/invenio_app_rdm/deposit/index.js"
  (invenio_app_rdm/theme/assets/semantic-ui/js/invenio_app_rdm/deposit/index.js)

``index.js`` references ``RDMDepositForm.js`` in same directory.

 




