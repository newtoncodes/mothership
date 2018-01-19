#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

echo "Domain: "
read domain;

mkdir -p /etc/mothership/gitlab/vpn
cp -f ${dir}/vhost.conf /etc/mothership/gitlab/vhost.conf
cp -f ${dir}/stack.yml /etc/mothership/gitlab/stack.yml

sed -i "s/{{DOMAIN}}/$domain/" /etc/mothership/gitlab/vhost.conf

docker volume create gitlab_config > /dev/null
docker volume create gitlab_log > /dev/null
docker volume create gitlab_data > /dev/null
docker network create --attachable gitlab > /dev/null
