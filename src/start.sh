#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

docker stack deploy --compose-file /etc/mothership/##app##.yml --with-registry-auth mothership_##app##
cp -f /etc/mothership/templates/##app##.conf /etc/mothership/vhosts-private/##app##.conf

if [ -f /etc/mothership/templates/##app##.conf.public ]; then
    cp -f /etc/mothership/templates/##app##.conf /etc/mothership/vhosts-public/##app##.conf
fi

set +e

mothership-webserver-stop
mothership-webserver-start
