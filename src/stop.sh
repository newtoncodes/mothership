#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

docker stack rm mothership_##app##
rm -rf /etc/mothership/vhosts/##app##.conf

set +e

mothership-webserver-stop
mothership-webserver-start
