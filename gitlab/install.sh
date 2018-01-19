#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

mkdir -p /etc/mothership/bookstack/vpn

docker volume create gitlab_config > /dev/null
docker volume create gitlab_log > /dev/null
docker volume create gitlab_data > /dev/null
docker network create --attachable gitlab > /dev/null
