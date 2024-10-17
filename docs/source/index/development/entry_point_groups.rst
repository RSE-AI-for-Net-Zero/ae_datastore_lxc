Entry point groups
==================
Get a list of entry point groups.



::
   
   (container) $: . /opt/invenio/src/.venv/bin/activate
   (src) $: python
   
::  

   >>> from importlib.metadata import entry_points
   >>> for _ in sorted(entry_points()): print(_)

List entry points in group (note: we're using Python 3.9's version of the importlib API)::

  >>> for _ in entry_points()['flask.commands']: print(_)
  ...
  
  EntryPoint(name='access', value='invenio_access.cli:access', group='flask.commands')
  EntryPoint(name='users', value='invenio_accounts.cli:users', group='flask.commands')
  ...

``flask.commands``
------------------

Loaded as CLI subcommands (beneath ``ae-datastore``)
