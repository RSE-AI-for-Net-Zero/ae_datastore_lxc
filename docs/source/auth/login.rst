=================
Login UI
=================

---------
As-is
---------

^^^^^^^^^^^^^^^^^^
Config
^^^^^^^^^^^^^^^^^^
::

   OAUTHCLIENT_AUTO_REDIRECT_TO_EXTERNAL_LOGIN = False
   ACCOUNTS_LOCAL_LOGIN_ENABLED = True
   SECURITY_TRACKABLE = True
   SECURITY_LOGIN_USER_TEMPLATE = 'invenio_accounts/login_user.html'
   SECURITY_POST_LOGIN_VIEW = '/'

^^^^^^^^^^^^^^^^^^
Form
^^^^^^^^^^^^^^^^^^
flask_security.forms.LoginForm (flask_security.forms.Form, flask_security.forms.NextFormMixin)
flask_security.forms.Form (flask_wtf.forms.Form)

Time limit, next form mixin and CSRF.

Checks if password is recoverable on initialisation and creates and stores a redirect as instance attribute.

Validate method sends some useful messages back to client.  E.g., user doesn't exist, invalid password, etc.

^^^^^^^^^^^^^^^^^^
Template
^^^^^^^^^^^^^^^^^^

``SECURITY_LOGIN_USER_TEMPLATE``

^^^^^^^^^^^^^^^^^^
Signals
^^^^^^^^^^^^^^^^^^
What is listening to these?

``identity_changed``
``user_logged_in``

^^^^^^^^^^^^^^^^^^
Workflow
^^^^^^^^^^^^^^^^^^
								
``invenio_oauthclient.views.client.auto_redirect_login`` is the view function registered to handle login requests. Under current configuration the request is passed straight on to ``invenio_accounts.views.login``, which in turn passes the onto ``flask_security.views.login``.

``flask_security.views.login``
- form - invenio_accounts.forms.login_form_factory() plainly returns a subclass of flask_security.forms.LoginForm with name ``app`` in ``locals``.

if validate on submit:
- ``login_user(form.user)``
- calls flask_login.login_user(form.user, False)
  - sets ``session['_user_id']``, ``session['_fresh']`` and ``session['_id']``
  - updates request context with user (``current_app.login_manager._update_request_context_with_user(user``)
  - sends user_logged_in signal
    
 
- security is trackable, so sets user login info
 - sends ``identity_changed`` signal
- ``after_this_request``
- get_post_login_redirect

else:
render LOGIN_USER_TEMPLATE




 





