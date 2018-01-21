#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

mkdir -p /etc/mothership/templates
mkdir -p /etc/mothership/vhosts-public
mkdir -p /etc/mothership/vhosts-private
mkdir -p /etc/mothership/vpn

cp -f ${dir}/stack.yml "/etc/mothership/apps/webserver.yml"
cp -f ${dir}/vhost.conf "/etc/mothership/templates/00-default.conf"
cp -f ${dir}/vhost.conf "/etc/mothership/vhosts-private/00-default.conf"
cp -f ${dir}/vhost.conf "/etc/mothership/vhosts-public/00-default.conf"

echo "#!/usr/bin/env bash

docker stack deploy --compose-file /etc/mothership/apps/webserver.yml --with-registry-auth webserver
" > /usr/local/bin/mothership-webserver-start

echo "#!/usr/bin/env bash

docker stack rm webserver
" > /usr/local/bin/mothership-webserver-stop

chmod +x "/usr/local/bin/mothership-webserver-start"
chmod +x "/usr/local/bin/mothership-webserver-stop"
