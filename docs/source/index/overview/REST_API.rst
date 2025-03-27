^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Records management via REST API
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The main docs for the REST API are `here <https://inveniordm.docs.cern.ch/reference/rest_api_index/>`_.

The files in :file:`tests/` contain examples of a draft creation - file upload - publish workflow using both access tokens and the ldap credentials to authenticate the user.  If you're going to build a browser-based app that makes API calls in the background to handle this workflow then the latter would be better suited since you have to store the session and CSRF cookies and also set the referrer (*Referer* header) to one of the trusted hosts.  Note that you won't documentation for this at Invenio's website - they say only access tokens are supported.

A good thing to have would be a user-friendly search interface.  The following API call is an example of how the extra metadata can be searched::

   SEARCH_QUERY="metadata.domain_metadata.entry_type.colour:blue"
   curl https://data-dev.ae.ic.ac.uk/api/records?q=${SEARCH_QUERY} | python -m json.tool

This is pretty clunky.  There's a concept of "search facet" in the packages *invenio-records-resources*, *invenio-rdm-records* and *invenio-search* which appears to provide a customisation point for constructing and transmitting search queries, but it's not that well documented.  Opensearch's API for searches is extensive and worth having a close look at.

