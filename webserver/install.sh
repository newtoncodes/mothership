#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

mkdir -p /etc/mothership/templates
mkdir -p /etc/mothership/vhosts
mkdir -p /etc/mothership/vpn

cp -f ${dir}/webserver/stack.yml "/etc/mothership/webserver.yml"

cp -f ${dir}/start.sh "/usr/local/bin/mothership-webserver-start"
cp -f ${dir}/start.sh "/usr/local/bin/mothership-webserver-stop"

sed -i "s/{{app}}/webserver/" "/usr/local/bin/mothership-webserver-start"
sed -i "s/{{app}}/webserver/" "/usr/local/bin/mothership-webserver-stop"

chmod +x "/usr/local/bin/mothership-webserver-start"
chmod +x "/usr/local/bin/mothership-webserver-stop"