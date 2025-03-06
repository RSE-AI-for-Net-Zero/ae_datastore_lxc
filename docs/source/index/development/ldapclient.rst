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


Templates (no ldap)
^^^^^^^^^^^^^^^^^^^

``InvenioApp`` extension sets ``app.jinja_env.loader = ThemeJinjaLoader(...)``.  This prepends "semantic-ui/" (``app.config["APP_THEME"]``) to template references, so app first searches for templates beneath semantic-ui subdirectory and falls back to directly beneath "templates" if this fails.

Initial login template is set by ``app.config["SECURITY_LOGIN_USER_TEMPLATE"]``, which for a default install is "invenio_oauthclient/login_user.html".  This means that the template "semantic-ui/invenio_oauthclient/login_user.html" is search for in the template search path.

"semantic-ui/invenio_oauthclient/login_user.html" extends "semantic-ui/invenio_accounts/login_user.html"


also ...::

  from invenio_factory_patch.factory import create_app

  app = create_app()
  app.app_context().push()

  loader = app.jinja_env.loader
  loader.load(environment = app.jinja_env, name = "invenio_ldapclient/login_user.html")

gives::

  <Template 'semantic-ui/invenio_ldapclient/login_user.html'>




   
