#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

echo "Domain: "
read domain;

mkdir -p /etc/mothership/registry/vpn
cp -f ${dir}/vhost.conf /etc/mothership/registry/vhost.conf
cp -f ${dir}/stack.yml /etc/mothership/registry/stack.yml

sed -i "s/{{DOMAIN}}/$domain/" /etc/mothership/registry/vhost.conf


docker volume create registry_data > /dev/null
docker network create --attachable registry > /dev/null
