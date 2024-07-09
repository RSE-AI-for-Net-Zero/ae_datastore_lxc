### For all services
1. Check image env vars in `create_container.sh` (`DISTR`, `RELEA` and `ARCHE`)
2. Check the base config `lxc_config.conf` - this is currently set-up for default lxc networking via `lxcbr0`

### opensearch
1. Generate a set of self-signed SSL certs `./opensearch/utils/gen_self_signed_certs.sh`
2. Move them `mv *.pem opensearch/mount/scripts/`
3. build the service, e.g., 
   ```
   cd ae_datastore_lxc/opensearch/
   . build_data_node.sh opensearch_d1 ../lxc_config.conf /abs/path/to/host/data/mnt/pnt /abs/path/to/host/log/mnt/pnt
   ```
Steps 4-6 might not be necessary, but I suspect the hashing tool uses machine randomness to hash passwords. Perhaps skip this on a first
   go and if you get password troubles when testing the install come back and try this.

4. Use the opensearch security
   plug-in hashing tool to hash a pair of user passwords for the *admin* and *invenio_usr*
   passwords.
   ```
   export CLEARTXT_PASSWD='my_password_999'
   systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n NAME_OF_CONTAINER --clear-env \
                             --kep-var CLEARTXT_PASSWD -- /home/scripts/hash_passwd.sh
   ```
   Copy and paste the hashes into the relevant places in `opensearch/mount/scripts/config/single-node/opensearch-security/internal_users.yml` 

5. Restart the service
   ```
     systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n NAME_OF_CONTAINER --clear-env \
                           -- systemctl restart opensearch
   ```

6. Run the security config script
   ```
     systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n NAME_OF_CONTAINER --clear-env \
                           -- OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk \
                           /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh \
                          -cd /etc/opensearch/opensearch-security/ -cacert /etc/opensearch/root-ca.pem \
                          -cert /etc/opensearch/admin.pem -key /etc/opensearch/admin-key.pem -icl -nhnv

   ```
7.  Test (from the host)
    ```
    curl -X GET -u 'admin:my_password_999' --insecure https://IP_ADDR:9200
    curl -X GET -u 'admin:my_password_999' --insecure https://IP_ADDR:9200/_cat/indices
    ```
   
