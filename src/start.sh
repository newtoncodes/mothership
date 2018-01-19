#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

docker stack deploy --compose-file /etc/mothership/{{app}}.yml --with-registry-auth mothership_{{app}}
cp -f /etc/mothership/templates/{{app}}.conf /etc/mothership/vhosts/{{app}}.conf

set +e

mothership-webserver-stop
mothership-webserver-start
