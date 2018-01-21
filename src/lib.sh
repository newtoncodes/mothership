#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

install() {
    local password="$2"

    echo "Domain: "
    read domain;

    echo "Public (yes/no; default: no): "
    read public;

    mkdir -p /etc/mothership/templates
    mkdir -p /etc/mothership/vhosts-public
    mkdir -p /etc/mothership/vhosts-private
    mkdir -p /etc/mothership/vpn

    cp -f ${dir}/../apps/${1}/vhost.conf "/etc/mothership/templates/$1.conf"
    sed -i "s/{{DOMAIN}}/$domain/" "/etc/mothership/templates/$1.conf"
    sed -i "s/{{PASSWORD}}/$password/" "/etc/mothership/templates/$1.conf"

    if [ "$public" = "yes" ]; then
        touch "/etc/mothership/templates/$1.conf.public"
    fi

    cp -f ${dir}/../apps/${1}/stack.yml "/etc/mothership/$1.yml"
    sed -i "s/{{DOMAIN}}/$domain/" "/etc/mothership/$1.yml"
    sed -i "s/{{PASSWORD}}/$password/" "/etc/mothership/$1.yml"

    #

    cp -f ${dir}/start.sh "/usr/local/bin/mothership-$1-start"
    cp -f ${dir}/stop.sh "/usr/local/bin/mothership-$1-stop"

    sed -i "s/##app##/$1/g" "/usr/local/bin/mothership-$1-start"
    sed -i "s/##app##/$1/g" "/usr/local/bin/mothership-$1-stop"

    chmod +x "/usr/local/bin/mothership-$1-start"
    chmod +x "/usr/local/bin/mothership-$1-stop"
}

