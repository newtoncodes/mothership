#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

docker stack rm ##app##

set +e

rm -rf /etc/mothership/vhosts-public/##app##.conf
rm -rf /etc/mothership/vhosts-private/##app##.conf

mothership-webserver-stop
mothership-webserver-start
