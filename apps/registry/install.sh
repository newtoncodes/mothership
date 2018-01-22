#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${dir}/../../src/lib.sh

set -e

domain2=
install registry foo yes

#echo "LDAP users dn: "
#read ldapUsersDn;
#
#echo "LDAP search dn: "
#read ldapSearchDn;
#
#docker volume create registry_data > /dev/null
#docker volume create registry_config > /dev/null
#docker volume create registry_auth_config > /dev/null
#docker volume create registry_auth_log > /dev/null

cp ${dir}/registry.yml /var/lib/docker/volumes/registry_config/_data/config.yml
#cp ${dir}/auth.ldap.yml /var/lib/docker/volumes/registry_auth_config/_data/auth.ldap.yml
#cp ${dir}/auth.simple.yml /var/lib/docker/volumes/registry_auth_config/_data/auth.simple.yml

#sed -i "s/{{SEARCH_DN}}/$ldapSearchDn/" /var/lib/docker/volumes/registry_auth_config/_data/auth.ldap.yml
#sed -i "s/{{USERS_DN}}/$ldapUsersDn/" /var/lib/docker/volumes/registry_auth_config/_data/auth.ldap.yml
sed -i "s/{{HOST}}/$domain2/" /var/lib/docker/volumes/registry_config/_data/config.yml

#ldapSearchPassword=$(pwgen -1 32)
#echo "$ldapSearchPassword" > /var/lib/docker/volumes/registry_auth_config/_data/bind-password.txt

#echo ""
#echo "Search dn password: $ldapSearchPassword"
#echo ""
