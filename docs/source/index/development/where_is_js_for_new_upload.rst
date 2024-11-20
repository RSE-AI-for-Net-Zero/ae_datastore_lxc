Where's the javascript for new upload?
--------------------------------------

Say we want to hack at the upload functionality in the app. First thing we need to do is locate the existing javascript that creates the upload form in the browser.

The URI for new uploads is ``/uploads/new``.  To find the corresponding end point::

  $: ae-datastore routes | grep '/uploads

This gives::

  invenio_app_rdm_records.deposit_create      GET        /uploads/new
  invenio_app_rdm_records.deposit_edit        GET        /uploads/<pid_value>
  invenio_app_rdm_users.uploads               GET        /me/uploads

To locate the view function, open a python interpreter and::

  >>> from invenio_factory_patch.factory import create_app
  >>> app = create_app()
  >>> f = app.view_functions['invenio_app_rdm_records.deposit_create']
  >>> f.__name, f.__module__

  ('deposit_create', 'invenio_app_rdm.records_ui.views.deposits')

This function renders the template specified with config key ``APP_RDM_DEPOSIT_FORM_TEMPLATE``, so::

  >>> app.config['APP_RDM_DEPOSIT_FORM_TEMPLATE']

  'invenio_app_rdm/records/deposit.html'

This template contains::

  {%- block javascript %}
    {{ super() }}
    {{ webpack['invenio-app-rdm-deposit.js'] }}
  {%- endblock %}

This means the all relevant code is bundled by ``webpack`` into the static asset ``invenio-app-rdm-deposit.js``.  To find what code was bundled, look at::

  .../lib/python3.9/site-packages/invenio_app_rdm-11.0.6.dist-info/entry_points.txt

This file contains the entry::

  [invenio_assets.webpack]
  invenio_app_rdm_theme = invenio_app_rdm.theme.webpack:theme

This gives us the location of the files bundled by webpack to create the asset.  The directory::

  .../lib/python3.9/site-packages/invenio_app_rdm/theme

contains ``webpack.py``, which tells us where to find the code::

  "invenio-app-rdm-deposit": "./js/invenio_app_rdm/deposit/index.js",

I.e.,::

  .../lib/python3.9/site-packages/invenio_app_rdm/theme/assets/semantic-ui/js/invenio_app_rdm/deposit





 

  

  






