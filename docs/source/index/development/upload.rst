New upload
==========
Installed RDM v12.0::
  invenio-cli init -c v12.0 RDM

::
   pipenv run pip list

Installs the following dependencies::
   ...
   invenio-app-rdm               12.0.1
   invenio-drafts-resources      3.2.0
   invenio-rdm-records           10.9.1
   invenio-records               2.4.1
   invenio-records-files         1.2.1
   invenio-records-permissions   0.21.0
   invenio-records-resources     5.10.1
   invenio-records-rest          2.4.1
   invenio-records-ui            1.2.2
   invenio-requests              4.1.2
   invenio-rest                  1.5.0
   ...

Get view function for ``uploads/new``::

   pipenv run invenio routes | grep "uploads/new"

::
   
   invenio_app_rdm_records.deposit_create	GET	/uploads/new


::

   >>> from invenio_app.factory import create_app
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

``index.js`` references ``RDMDepositForm.js`` in same directory.  ``RDMDepositForm`` is a react component.

js stuff
--------

React
^^^^^
`<https://react.dev/learn/describing-the-ui>`_

- JSX - rules
- javascript goes in curly braces
- passing props to components
- components assumed to be *pure*

Redux
^^^^^


`react-redux <https://react-redux.js.org/introduction/getting-started>`_: react UI bindings layer for `redux <https://redux.js.org/>`_.  Lets react components read data from a Redux store and dispatch actions to the store to update state.

Formik
^^^^^^




 




