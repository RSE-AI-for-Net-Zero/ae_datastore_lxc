To do's, outstanding issues and bits and pieces
-----------------------------------------------

1. Choose better passwords - in fact, have another go at using `systemd's credential management <https://systemd.io/CREDENTIALS/>`_ - you might have better luck than I did - rather than exporting the passwords into the shell environment.  The systemd way stops passwords leaking into child processes.

2. Set up db snap shot and WALs and process for moving these to a remote backup location

3. Set up back-ups for Opensearch indices that cannot be recreated from db (see :ref:`opensearch_ref`)

4. I made a start on adding a system field (see the diagram below) to the internal record and draft classes in :file:`invenio_rdm_domain_records/records/api.py` on the *slow-changing-constant-field* branch.  This system field is a subclass of the ``ConstantField`` system field class. The idea is that by hooking into the *pre_init* record extension hook, you can automatically add the current version of *ae-datastore-schemas* to the record (which you can get from the package).  You'll notice that Invenio just uses a ConstantField, for the schema field, which adds the schema version if it's missing, but if it's present in the record it does nothing.  But what happens when someone comes along and creates a new version of a published record, but the schema version has been incremented since the record was published?  I think I've hit on the way to fix that, but it needs some proper testing, hence why it's not merged into main.


^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Important warning: changing the SECRET_KEY
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The SECRET_KEY config setting is used by Flask to encrypt the session cookie, but Invenio might be using it for other purposes.  When moving the SECRET_KEY out of :file:`invenio.cfg` - where it was stored in plain text- and putting it into :file:`/etc/conf.d/secrets` (and setting it to something other than "change me") I noticed that the *Applications* menu option in the GUI for the dev instance started giving an Internal Server Error and the logs said something about an invalid encryption key.  Not having time to properly investigate this, I just re-initalised the dev instance and everything's ok again, but I'm guessing changing the key caused some real issues.


^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Record class hierarchy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

I've put together a few random diagrams in :file:`docs/source/diagrams.records.drawio`, such as this one

.. image:: /images/record_class_hierarchy.drawio.png 


	   
You'll need `drawio <https://www.drawio.com/>`_ to open and edit these.

