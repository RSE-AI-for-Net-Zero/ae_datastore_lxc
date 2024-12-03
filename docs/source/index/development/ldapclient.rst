invenio-ldapclient
------------------

Templates
^^^^^^^^^

Invenio-Accounts v2.0.2, registers a blueprint with no view functions.  One of the desired side effects is to place ``invenio_accounts/templates`` into the app's template search path.

``security/login_user.html``
   - extends ``config.LDAPCLIENT_BASE_TEMPLATE`` (``invenio_accounts/base.html``)
   - imports ``invenio_accounts/_macros.html``

Inv-Acc Dependency Hell
^^^^^^^^^^^^^^^^^^^^^^^

To test with older versions of dependencies

::

   export PYENV_VERSION=3.9
   python -m venv .rdm-venv
   . .rdm-venv/bin/activate
   pip install --upgrade pip
   pip install 'invenio-app-rdm[postgresql, opensearch2]==11.0.6'
   pip install -e '.[dev]'
   pytest

Useful::

  git checkout v2.0.2
  git diff v3.5.2 -- invenio_accounts/views/rest.py
  git diff v3.5.2 v4.0.2 -- invenio_accounts/views/rest.py
  git diff v4.0.2 master -- invenio_accounts/views/rest.py


   
