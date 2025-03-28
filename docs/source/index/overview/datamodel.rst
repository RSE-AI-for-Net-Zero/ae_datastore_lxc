-----------
Data model
-----------

The metadata model in its entirety is expressed in :file:`invenio_rdm_domain_records/records/jsonschemas/records/domain-record-v6.0.0.json`.  You'll see that this schema's *metadata* property contains the subschema ::

  "domain_metadata": {
       "type": "object",
       "$ref": "local://domain/root.json"
  }

The url `<local://domain/root.json>`_ points to :file:`root.json` in *ae-datastore-schema* **after** the schema package has been loaded into the app's internal schema registy by *invenio-jsonschemas* at load time.  The Aeronautics domain-specific metadata schema should be kept under version control somewhere - e.g., `here <https://github.ic.ac.uk/aeronautics/ae-datastore-schemas>`_ and its current version should be accessible at run time - e.g., using a module attribute ``ae_datastore_schemas.__version__``.  Apparently the build tool `setuptools-scm <https://pypi.org/project/setuptools-scm/>`_ can be used to extract the current package version from a git ref.

Following an update to the data model, the schema package will have to be updated in the *rdm-invenio* containers (see :ref:`basecontainer_ref`).

See the to-do's on some thoughts about injecting the current Aeronautics schema version into records and drafts via a systemfield (you'll find an initial go at this on the *slow-changing-constant-field* branch of the `invenio-rdm-domain-records <https://github.ic.ac.uk/aeronautics/invenio-rdm-domain-records>`_ repo).


  

