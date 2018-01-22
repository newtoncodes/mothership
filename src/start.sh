#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

if [ ! -f "/etc/mothership/certs/ca.crt" ]; then
    echo "Place the following files in /etc/mothership/certs:"
    echo "  ca.crt, server.crt, server.bundle.crt (crt + ca), server.key"
    exit 1;
fi

if [ ! -f "/etc/mothership/certs/server.crt" ]; then
    echo "Place the following files in /etc/mothership/certs:"
    echo "  ca.crt, server.crt, server.bundle.crt (crt + ca), server.key"
    exit 1;
fi

if [ ! -f "/etc/mothership/certs/server.bundle.crt" ]; then
    echo "Place the following files in /etc/mothership/certs:"
    echo "  ca.crt, server.crt, server.bundle.crt (crt + ca), server.key"
    exit 1;
fi

if [ ! -f "/etc/mothership/certs/server.key" ]; then
    echo "Place the following files in /etc/mothership/certs:"
    echo "  ca.crt, server.crt, server.bundle.crt (crt + ca), server.key"
    exit 1;
fi

docker stack deploy --compose-file /etc/mothership/apps/##app##.yml --with-registry-auth ##app##
cp -f /etc/mothership/vhosts-tpl/##app##.conf /etc/mothership/vhosts-private/##app##.conf

if [ -f /etc/mothership/vhosts-tpl/##app##.conf.public ]; then
    cp -f /etc/mothership/vhosts-tpl/##app##.conf /etc/mothership/vhosts-public/##app##.conf
fi

set +e

mothership-webserver-stop
mothership-webserver-start
