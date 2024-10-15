#!/bin/bash

cp -R /home/host/config /tmp

ldapadd -x -D 'cn=admin,dc=example,dc=com' -H ldapi:/// -w ${LDAP_PASSWD} \
	-f /tmp/config/add_org_units.ldif


GID_NUMBER=1

for GROUP_NAME in red green blue
do
    sed """
    s/<group_name>/${GROUP_NAME}/
    s/<gid_number>/${GID_NUMBER}/
    s/<bind_base>/ou=Groups,ou=Local,dc=example,dc=com/
    """ tmp/config/add_group.ldif.tmpl | \

	ldapadd -x -D 'cn=admin,dc=example,dc=com' -w ${LDAP_PASSWD} -H ldapi:///

    echo $((GID_NUMBER++)) > /dev/null
done

for UID_NUMBER in $(seq 1 20)
do
    sed """
    s/<user_uid>/user_${UID_NUMBER}/
    s/<uid_number>/${UID_NUMBER}/
    s/<gid_number>/0/
    s/<bind_base>/ou=People,ou=Local,dc=example,dc=com/
    """ tmp/config/add_internal_user.ldif.tmpl | \

	ldapadd -x -D 'cn=admin,dc=example,dc=com'  -w ${LDAP_PASSWD} -H ldapi:///
    
    ldappasswd -x -D 'cn=admin,dc=example,dc=com' -w ${LDAP_PASSWD} -H ldapi:/// \
	       -s secret123 uid=user_${UID_NUMBER},ou=People,ou=Local,dc=example,dc=com
    
done


for UID_NUMBER in $(seq 21 25)
do
    sed """
    s/<user_uid>/external_user_${UID_NUMBER}/
    s/<bind_base>/ou=People,ou=External,dc=example,dc=com/
    """ tmp/config/add_external_user.ldif.tmpl | \

	ldapadd -x -D 'cn=admin,dc=example,dc=com'  -w ${LDAP_PASSWD} -H ldapi:///

    ldappasswd -x -D 'cn=admin,dc=example,dc=com' -w ${LDAP_PASSWD} -H ldapi:/// \
	       -s secret123 uid=external_user_${UID_NUMBER},ou=People,ou=External,dc=example,dc=com

done




