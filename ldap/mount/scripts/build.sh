#!/bin/bash

apt update && \
    apt install -y openssh-server slapd ldap-utils openssl && \
    dpkg-reconfigure slapd

ip4=`ip addr show eth0 | grep -Po 'inet \K[\d.]+'`
if [[ -n "${ip4}" ]]; then
   echo "ip address of eth0:" ${ip4};
else
    exit 1;
fi
   
URI='ldap://example.com'
echo "BASE dc=example,dc=com" >> /etc/ldap/ldap.conf
echo ${URI} >> /etc/ldap/ldap.conf

printf "${ip4}\t${URI}\n" >> /etc/hosts

