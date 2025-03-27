.. _opensearch_ref:

OpenSearch
----------


How do I change passwords?
^^^^^^^^^^^^^^^^^^^^^^^^^^

Inside container, first get a hash of new password::

  NEW_PASSWD="..."
  ./root/scripts/hash_passwd.sh ${NEW_PASSWD}

This puts the hashed password into a file named ``hashed.psswd``.  Copy and paste its into the appropriate *hash* field in ``/etc/opensearch/opensearch-security/internal_users.yml`` then run the security config script and restart the service::

  OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh -cd /etc/opensearch/opensearch-security/ -cacert /etc/opensearch/certs/root-ca.pem -cert /etc/opensearch/certs/admin.pem -key /etc/opensearch/keys/admin-key.pem -icl -nhnv

  systemctl restart opensearch


Searching records and drafts by domain-metadata terms
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Suppose we've created a record with title "Test Record", with domain metadata::

  {
  	"entry_type": {
		"longitude": 22.0,
		"latitude": 22.0
		}
  }

We can see that Opensearch has dynamically created the search terms "longitude" and "latitude" by querying its mapping endpoint for the drafts index (from inside *rdm-invenio-ui-green*)::
  
  curl -k -u "ae-datastore:${PASSWD}" \
  https://rdm-opensearch-d1-dev:9200/ae-datastore-rdmdomainrecords-records/_mapping \
  | python -m json.tool | grep -A 20 -F "domain_metadata"

returns::

  ...
  "domain_metadata": {
      "dynamic": "true",
      "properties": {
          "entry_type": {
              "properties": {
                  "latitude": {
                      "type": "float"
                  },
                  "longitude": {
                      "type": "float"
                  }
              }
          }
      }
  },...


We can use `Opensearch's search API directly <https://opensearch.org/docs/2.15/api-reference/search/>`_ to search for our record by term using a `dotted query <https://opensearch.org/docs/latest/query-dsl/joining/nested/>`_ (from inside *rdm-invenio-ui-green*)::

  curl -k -u "ae-datastore:${PASSWD}" \
  -H "Content-type: application/json" \
  https://rdm-opensearch-d1-dev:9200/ae-datastore-rdmdomainrecords-records/_search \
  -d '{"query": {"match": {"metadata.domain_metadata.entry_type.longitude": 22.0}}}' \
  | python -m json.tool | grep -A 10 -B 10 -F "longitude"


gives us a search result, whereas::

  curl -k -u "ae-datastore:${PASSWD}" \
  -H "Content-type: application/json" \
  https://rdm-opensearch-d1-dev:9200/ae-datastore-rdmdomainrecords-records/_search \
  -d '{"query": {"match": {"metadata.domain_metadata.entry_type.longitude": 22222222.0}}}' \
  | python -m json.tool | grep -A 10 -B 10 -F "longitude"

gives us nothing.

Note that we're passing the search query in the request body.  `InvenioRDM record search API <https://inveniordm.docs.cern.ch/reference/rest_api_drafts_records/#search-records>`_ requires the search query in the URL parameter string under the key "q" using Lucene search query syntax.

This works (from somewhere where data-dev.ae.ic.ac.uk is accessible)::

  SEARCH_QUERY="metadata.domain_metadata.entry_type.longitude:22.0"
  curl https://data-dev.ae.ic.ac.uk/api/records?q=${SEARCH_QUERY} | python -m json.tool

and do does this::
  
  SEARCH_QUERY="title:Test%20Record"
  curl https://data-dev.ae.ic.ac.uk/api/records?q=${SEARCH_QUERY} | python -m json.tool


but this::

  SEARCH_QUERY="metadata.domain_metadata.entry_type.longitude:222222.0"
  curl https://data-dev.ae.ic.ac.uk/api/records?q=${SEARCH_QUERY} | python -m json.tool


and this::

  SEARCH_QUERY="metadata.domain_metadata.colour:blue"
  curl https://data-dev.ae.ic.ac.uk/api/records?q=${SEARCH_QUERY} | python -m json.tool

return nothing.

**Backing up search indices**
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Most of the search indices can be rebuilt from the app's database via the command line::

  ae-datastore index reindex
  ae-datastore index run

So there's no need to back-up most of them. However, it seems that in v12 there begin to be certain indices that cannot be rebuilt, and so will require backing up - `see here <https://inveniordm.docs.cern.ch/develop/howtos/backup_search_indices/>`_


  

  
  


