Up to now I've found no way to configure LXC and/or dnsmasq to produce predictable container IP addresses and there are several places where these are hard-coded into the scripts.  Please bear this in mind.

### For all services
1. Check image env vars in `create_container.sh` (`DISTR`, `RELEA` and `ARCHE`)
2. Check the base config `lxc_config.conf` - this is currently set-up for default lxc networking via `lxcbr0`

### opensearch
1. Generate a set of self-signed SSL certs `./opensearch/utils/gen_self_signed_certs.sh`
2. Move them `mv *.pem *.srl opensearch/mount/config/single-node/`
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

## PostgreSQL
1. Build the container (first set `TRUSTED_HOST` environment variable in `postgres/build.sh`.  I currently have it set to the IPv4 address of my lxcbr0 device. The server will accept unauthenticated connections from here and will refuse connections from anywhere else other than loopback interface).

```
cd postgres
. build.sh postgres_1 ../lxc_config.conf /abs/path/to/host/data/mnt/pnt
```
2. There is a script to test the build: `postgres/test_build.sh`.  It should be fairly self-explanatory, but will require some manual set-up - see the comments in the script.

### Shutting down the server

- Three shutdown modes: **smart** (SIGTERM), **fast** (SIGINT) and **immediate** (SIGQUIT).  Prefer **smart** mode - server refuses any new connections then waits for all sessions to terminate before shutting down.  Apparently, [systemd doesn't handle shutdown modes well](https://dba.stackexchange.com/questions/307781/proper-smart-shutdown-of-postgresql-server-for-pgdg-apt-packages-under-ubuntu), and so to smart shutdown a debian install do

```
su postgres -c 'pg_ctlcluster --mode smart 15 ae_data stop --skip-systemctl-redirect' 
```
or, [send a SIGTERM](https://www.postgresql.org/docs/15/server-shutdown.html)

```
kill -s SIGTERM <pid>
```
Add `lxc.signal.stop = SIGTERM` to LXC container config.  When container is stopped, all processes are then sent SIGTERM (defaults to SIGKILL, which is **bad in production**) and the server shuts down gracefully.

## Rabbitmq
1.  If you've succeeded with the first two, then this should be a breeze.  There's no host data mount, so to build the service
```
cd rabbitmq; . build.sh rabbitmq ../lxc_config.conf
```
2.  Again, there's a test script, `test_build.sh`, which will require creating a python virtualenv and installing
   a client package and replacing the container's IP address.

## Redis
Pretty much the same as above. The way you're supposed to configure redis-server to listen on all interfaces doesn't seem to be documented, but by infuriating trial-and-error I got it to work with `bind 0.0.0.0`.  The build should work without problems
```
cd redis; . build.sh redis ../lxc_config.conf
```
There is also a python script to ping the server from outside the container.  You'll need to run this is in an environment where `python -c import redis` works (e.g., in a virtualenv after `pip install --upgrade pip redis`).  Again, watch out for hard coded IP addresses lurking in the scripts.
