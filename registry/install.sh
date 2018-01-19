#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

mkdir -p /etc/mothership/registry/vpn
cp -f ${dir}/vhost.conf /etc/mothership/registry/vhost.conf

docker volume create registry_data > /dev/null
docker network create --attachable registry > /dev/null
