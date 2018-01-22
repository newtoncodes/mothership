#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${dir}/../../src/lib.sh

set -e

install ldap

echo "LDAP domain: $domain"

echo "LDAP organization: "
read org;

echo "LDAP users dn: "
read ldapUsersDn;

echo "LDAP search dn: "
read ldapSearchDn;

ldapSearchPassword=$(pwgen -1 32)

docker run --rm -it -d \
    -e "LDAP_ORG=$org" \
    -e "LDAP_DOMAIN=$domain" \
    -e "LDAP_HOST=ldap" \
    -e "LDAP_PORT=389" \
    -e "LDAP_USERS_DN=$ldapUsersDn" \
    -e "LDAP_SEARCH_DN=$ldapSearchDn" \
    -e "LDAP_SEARCH_PASSWORD=$ldapSearchPassword" \
    -v ldap_admin:/var/lib/ldap-account-manager \
    --name=ldap_admin_tmp \
newtoncodes/ldap-account-manager:5.2

id=$(docker ps | grep ldap_tmp | awk '{print $1;}')

sleep 5
docker stop ${id} > /dev/null

echo "Admin configured."


exit 0;

docker volume create ldap_certs > /dev/null
docker volume create ldap_config > /dev/null
docker volume create ldap_data > /dev/null
docker volume create ldap_admin > /dev/null

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

passwordAdmin=$(pwgen -1 32)
passwordConfig=$(pwgen -1 32)

docker run --rm -it -d \
    -e "LDAP_LOG_LEVEL=256" \
    -e "LDAP_ORGANISATION=$org" \
    -e "LDAP_DOMAIN=$domain" \
    -e "LDAP_ADMIN_PASSWORD=$passwordAdmin" \
    -e "LDAP_CONFIG_PASSWORD=$passwordConfig" \
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

id=$(docker ps | grep ldap_tmp | awk '{print $1;}')

set +e
echo "LDAP first start in progress..."
ready=

for i in {30..0}; do
    sleep 10

    if [ "$ready" != "" ]; then break; fi

    ready=$(docker logs ${id} 2> /dev/null | grep "slapd starting")
done

if [ "$i" = 0 ]; then
    docker stop ${id} > /dev/null
    echo >&2 "LDAP init process failed."
    exit 1
fi

echo "LDAP started ok."

sleep 5;

docker cp /tmp/tmp-change.ldif ldap_tmp:/tmp-change.ldif

echo "File copied"
echo "Tmp id: $id"

docker exec -it ${id} ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp-change.ldif
docker exec -it ${id} ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config 'olcDatabase={0}hdb'

docker stop ${id} > /dev/null

echo ""
echo "Admin: $passwordAdmin"
echo "Config: $passwordConfig"
echo ""