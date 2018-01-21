#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

checkCerts() {
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
}

install() {
    checkCerts

    local password="$2"

    echo "Domain: "
    read domain;

    echo "Public (yes/no; default: no): "
    read public;

    mkdir -p /etc/mothership/apps
    mkdir -p /etc/mothership/snet
    mkdir -p /etc/mothership/certs
    mkdir -p /etc/mothership/vhosts-tpl
    mkdir -p /etc/mothership/vhosts-public
    mkdir -p /etc/mothership/vhosts-private

    cp -f ${dir}/../apps/${1}/vhost.conf "/etc/mothership/vhosts-tpl/$1.conf"
    sed -i "s/{{DOMAIN}}/$domain/" "/etc/mothership/vhosts-tpl/$1.conf"
    sed -i "s/{{PASSWORD}}/$password/" "/etc/mothership/vhosts-tpl/$1.conf"

    if [ "$public" = "yes" ]; then
        touch "/etc/mothership/vhosts-tpl/$1.conf.public"
    fi

    cp -f ${dir}/../apps/${1}/stack.yml "/etc/mothership/apps/$1.yml"
    sed -i "s/{{DOMAIN}}/$domain/" "/etc/mothership/apps/$1.yml"
    sed -i "s/{{PASSWORD}}/$password/" "/etc/mothership/apps/$1.yml"

    #

    cp -f ${dir}/start.sh "/usr/local/bin/mothership-$1-start"
    cp -f ${dir}/stop.sh "/usr/local/bin/mothership-$1-stop"

    sed -i "s/##app##/$1/g" "/usr/local/bin/mothership-$1-start"
    sed -i "s/##app##/$1/g" "/usr/local/bin/mothership-$1-stop"

    chmod +x "/usr/local/bin/mothership-$1-start"
    chmod +x "/usr/local/bin/mothership-$1-stop"
}

