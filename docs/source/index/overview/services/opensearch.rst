.. _opensearch_ref:

OpenSearch
----------

.. [!ToDo!] Single data for opensearch

How do I change passwords?
^^^^^^^^^^^^^^^^^^^^^^^^^^

Inside container, first get a hash of new password::

  NEW_PASSWD="..."
  ./root/scripts/hash_passwd.sh ${NEW_PASSWD}

This puts the hashed password into a file named ``hashed.psswd``.  Copy and paste its into the appropriate *hash* field in ``/etc/opensearch/opensearch-security/internal_users.yml`` then run the security config script and restart the service::

  OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh -cd /etc/opensearch/opensearch-security/ -cacert /etc/opensearch/certs/root-ca.pem -cert /etc/opensearch/certs/admin.pem -key /etc/opensearch/keys/admin-key.pem -icl -nhnv

  systemctl restart opensearch


**Backing up search indices**
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Most of the search indices can be rebuilt from the app's database via the command line::

  ae-datastore index reindex
  ae-datastore index run

So there's no need to back-up most of them. However, it seems that in v12 there begin to be certain indices that cannot be rebuilt, and so will require backing up - `see here <https://inveniordm.docs.cern.ch/develop/howtos/backup_search_indices/>`_


  

  
  


