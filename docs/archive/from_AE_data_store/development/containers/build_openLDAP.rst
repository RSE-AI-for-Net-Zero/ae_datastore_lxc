===============================
Build the openLDAP container
===============================

Having built and started an unpriviledged lxc container named openLDAP (see --- link ---)

Copy config scripts from host into container (substitute user name and IP address for container)::

  (host) sftp <user_name>@10.0.x.x
  (sftp>) lcd /scripts/lxc/openLDAP_fs
  (sftp>) put *
  (sftp>) exit

Attach container to current terminal::

  lxc-attach openLDAP

Run config::

  ./config.sh
 
Respond to the following prompts:

- Adminsistrator password: *set a password*
- Omit OpenLDAP server configuration? *No*
- DNS doman name: *example.com*
- Organization name: *example*
- Do you want the database to be removed when slapd is purged? *No*
- Move old database? *Yes*

Finally, add Alice, Bob and Charlie to directory::

  export LDIF_SCRIPT_PATH=openLDAP_add_content.ldif
  ./add_people.sh
  

  








