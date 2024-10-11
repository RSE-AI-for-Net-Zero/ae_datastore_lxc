Invenio-Accounts config
-----------------------

``ACCOUNTS_RETENTION_PERIOD`` tasks.delete_ips

**invenio-ldapclient.views.ldap_login**



From invenio-ldapclient unit test ``test_invenio_ldapclient.py:test_init_non_exclusive_LDAP_auth`` both ``InvenioAccountsREST`` and ``InvenioAccountsUI`` have to be initialised before ``InvenioLDAPClient`` so that ``SECURITY_LOGIN_USER_TEMPLATE`` is properly set to ``LDAPCLIENT_LOGIN_USER_TEMPLATE``.

``invenio_ldapclient.LoginForm`` -> ``flask_security.forms.Form`` -> ``flask_wtf.FlaskForm`` -> ``wtforms.Form`` -> ``wtforms.BaseForm`` and ``wtforms.FormMeta`` (meta-class)

**Form**
``form.validate_on_submit`` defined in ``flask_wtf.forms.FlaskForm`` and is

1. There is an active request, with HTTP method in allowed list (``POST``, ``PUT``, ``PATCH``, or ``DELETE`` - even though Flask.blueprint might further restrict these)
2. The form's ``validate`` (defined in ``wtforms.BaseForm`` returns True with ``extra_validators`` passed as kwarg (TO DO: are these passed?)

Therefore, method must be POST or GET.  Flask complains first.  Otherwise, if no username or password submitted, render_template is called.  If username and password supplied and method is ok, we continue.

**babel**

Used ``pip-compile`` on invenio-ldapclient.  We end up with::

  babel==2.15.0
    # via
    #   flask-babel
    #   flask-babelex
    #   invenio-i18n

    ...

    flask-babel==4.0.0
    # via
    #   flask-security-invenio
    #   invenio-i18n
    
    flask-babelex==0.9.4
    # via
    #   invenio-ldapclient (pyproject.toml)
    #   invenio-userprofiles

``flask_babelex`` has the ``locale_selector`` attribute, not ``flask_babel``.

^^^^^^^^^^^^^
As-is
^^^^^^^^^^^^^
::
   OAUTHCLIENT_AUTO_REDIRECT_TO_EXTERNAL_LOGIN = False
   ACCOUNTS_LOCAL_LOGIN_ENABLED = True
   extensions['security'].login_form = invenio_accounts.forms.login_form_factory(extensions['security'].login_form,app)
   extensions['security'] = True
								
								
``invenio_oauthclient.views.client.auto_redirect_login`` is the view function registered to handle login requests. Under current configuration the request is passed straight on to ``invenio_accounts.views.login``, which in turn passes the onto ``flask_security.views.login``.

``flask_security.views.login``
- form - invenio_accounts.forms.login_form_factory() plainly returns a subclass of flask_security.forms.LoginForm with name ``app`` in ``locals``.

if validate on submit:
- ``login_user(form.user)``
- calls flask_login.login_user(form.user, False)
- security is trackable, so sets user login info
- sends `identity_changed` signal
- ``after_this_request``
- get_post_login_redirect

else:
render LOGIN_USER_TEMPLATE




 





