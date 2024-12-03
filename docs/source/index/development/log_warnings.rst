Warnings in ae-datastore log
----------------------------

::

   .../invenio_accounts/ext.py:245: UserWarning: The setup method 'route' can no longer be called on the blueprint 'invenio_accounts'. It has already been registered at least once, any changes will not be applied consistently.
   Make sure all imports, decorators, functions, etc. needed to set up the blueprint are done before registering it.
   This warning will become an exception in Flask 2.3.
   blueprint.route("/security/", methods=["GET"])(security)

``create_app`` loads both  ``invenio_accounts_ui`` and ``invenio_accounts_rest`` extensions, which each register the ``invenio_accounts`` blueprint.  This goes away when called ``create_ui`` or ``create_api``.

  
