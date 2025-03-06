Why is `semantic-ui` prepended to templates?
============================================

App config key ``APP_THEME`` is `semantic-ui`. Grepping for ``APP_THEME``, find in `invenio_app/ext.py`::

   # Add theme template loader
        if app.config.get("APP_THEME"):
            app.jinja_env.loader = ThemeJinjaLoader(app, app.jinja_env.loader)

``ThemeJinjaLoader`` (defined in `invenio_app/helpers.py`) "prefixes template loader" (according to comments) and invenio-app swaps this for the default template loader.


   
