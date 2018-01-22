#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${dir}/../../src/lib.sh

set -e

install registry

docker volume create registry_data > /dev/null
docker volume create registry_config > /dev/null
docker volume create registry_auth_config > /dev/null
docker volume create registry_auth_log > /dev/null

mv ${dir}/registry.yml /var/lib/docker/volumes/registry_config/_data/config.yml
mv ${dir}/auth.ldap.yml /var/lib/docker/volumes/registry_auth_config/_data/auth.ldap.yml
mv ${dir}/auth.simple.yml /var/lib/docker/volumes/registry_auth_config/_data/auth.simple.yml

openssl req -newkey rsa:4096 -nodes -sha256 -keyout /tmp/auth.key -x509 -days 1500 -out /tmp/auth.crt
openssl req -newkey rsa:4096 -nodes -sha256 -keyout /tmp/registry.key -x509 -days 1500 -out /tmp/registry.crt

cp /tmp/auth.crt /var/lib/docker/volumes/registry_auth_config/_data/auth.crt
cp /tmp/auth.key /var/lib/docker/volumes/registry_auth_config/_data/auth.key

mv /tmp/auth.crt /var/lib/docker/volumes/registry_config/_data/auth.crt
mv /tmp/auth.key /var/lib/docker/volumes/registry_config/_data/auth.key
mv /tmp/registrycp.crt /var/lib/docker/volumes/registry_config/_data/registry.crt
mv /tmp/registrycp.key /var/lib/docker/volumes/registry_config/_data/registry.key
