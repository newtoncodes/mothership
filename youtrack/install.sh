#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

mkdir -p /etc/mothership/youtrack/vpn
cp -f ${dir}/vhost.conf /etc/mothership/youtrack/vhost.conf

docker volume create youtrack_data > /dev/null
docker volume create youtrack_backup > /dev/null
docker network create --attachable youtrack > /dev/null
