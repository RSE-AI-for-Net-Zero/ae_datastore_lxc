#!/bin/bash

cp /home/host/config/ssl/example-dot-com.pem /etc/ssl/certs/
cp /home/host/config/ssl/example-dot-com-key.pem /etc/ssl/private/

chgrp openldap /etc/ssl/certs/example-dot-com.pem /etc/ssl/private/example-dot-com-key.pem

ldapmodify -H ldapi:/// -Y EXTERNAL << EOF
dn: cn=config
changetype: modify

add: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ssl/certs/example-dot-com.pem

-

add: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ssl/private/example-dot-com-key.pem

EOF
