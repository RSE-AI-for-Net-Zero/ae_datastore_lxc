============
SSL
============

Create dummy SSL cert::

  >>> from AE_data_store import create_app
  >>> from werkzeug.serving import make_ssl_devcert

  >>> make_ssl_devcert(create_app().instance_path)


Run dev server::

  >>> from AE_data_store import create_app
  >>> import os

  >>> app = create_app()

  >>> cert = os.path.join(app.instance_path, '.crt')
  >>> key = os.path.join(app.instance_path, '.key')

  >>> app.run(ssl_context=(cert,key), port=5001)

  

  

  
