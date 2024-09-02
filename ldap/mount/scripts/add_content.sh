#!/bin/bash

if [ -n $LDIF_SCRIPT_PATH ]; then
    ldapadd -x -D cn=admin,dc=example,dc=com -W -f $LDIF_SCRIPT_PATH
else
    ldapadd -x -D cn=admin,dc=example,dc=com -W -f /home/host/config/add_content.ldif
fi

       
for name in alice bob charlie
do
    echo "Setting password for" $name && \
    ldappasswd -x -D cn=admin,dc=example,dc=com -S uid=$name,ou=people,dc=example,dc=com \
	       -s monkey -w monkey && \
    echo "Password set for" $name
done
