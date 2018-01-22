#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${dir}/../../src/lib.sh

set -e

install ldap

docker volume create ldap_certs > /dev/null
docker volume create ldap_config > /dev/null
docker volume create ldap_data > /dev/null

echo "
dn: olcDatabase={1}hdb,cn=config
changetype: modify
delete: olcAccess
-
add: olcAccess
olcAccess: to dn.subtree=\"ou=users,dc=ldap,dc=newton,dc=codes\" attrs=entry,uid,cn,sn,givenName,mail,objectClass by dn.subtree=\"ou=auth,dc=ldap,dc=newton,dc=codes\" read by * break
olcAccess: to dn.subtree=\"ou=users,dc=ldap,dc=newton,dc=codes\" by dn.subtree=\"ou=auth,dc=ldap,dc=newton,dc=codes\" search by * break
olcAccess: to attrs=userPassword,shadowLastChange by self write by dn=\"cn=admin,dc=ldap,dc=newton,dc=codes\" write by anonymous auth by * none
olcAccess: to * by self write by dn="cn=admin,dc=ldap,dc=newton,dc=codes" write by * none
" > /tmp/tmp-change.ldif

docker cp ldap_data:tmp-change.ldif

echo "File copied"

exit 0;

docker run --privileged --rm -d -p 8881:80 -p 8882:443 \
    -e "LDAP_LOG_LEVEL=256" \
    -e "LDAP_ORGANISATION=$domain" \
    -e "LDAP_DOMAIN=$domain" \
    -e "LDAP_ADMIN_PASSWORD=admin" \
    -e "LDAP_CONFIG_PASSWORD=config" \
    -e "LDAP_READONLY_USER=false" \
    -e "LDAP_RFC2307BIS_SCHEMA=false" \
    -e "LDAP_BACKEND=hdb" \
    -e "LDAP_TLS=true" \
    -e "LDAP_TLS_CRT_FILENAME=ldap.crt" \
    -e "LDAP_TLS_KEY_FILENAME=ldap.key" \
    -e "LDAP_TLS_CA_CRT_FILENAME=ca.crt" \
    -e "LDAP_TLS_ENFORCE=false" \
    -e "LDAP_TLS_CIPHER_SUITE=SECURE256:-VERS-SSL3.0" \
    -e "LDAP_TLS_PROTOCOL_MIN=3.1" \
    -e "LDAP_TLS_VERIFY_CLIENT=try" \
    -e "LDAP_REPLICATION=false" \
    -e "KEEP_EXISTING_CONFIG=false" \
    -e "LDAP_REMOVE_CONFIG_AFTER_SETUP=true" \
    -e "LDAP_SSL_HELPER_PREFIX=ldap" \
    -v ldap_config:/etc/ldap/slapd.d \
    -v ldap_data:/var/lib/ldap \
    -v ldap_certs:/container/service/slapd/assets/certs \
    --name=ldap_tmp \
osixia/openldap:1.1.11

id=$(docker ps | grep iredmail_tmp | awk '{print $1;}')

echo "Tmp id: $id"

docker exec -it ${id} ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/t2.ldif
docker exec -it ${id} ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config 'olcDatabase={0}hdb'

echo ""
echo "LDAP is ready."