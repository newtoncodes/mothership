#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

mkdir -p /etc/mothership/templates
mkdir -p /etc/mothership/vhosts-public
mkdir -p /etc/mothership/vhosts-private
mkdir -p /etc/mothership/vpn

cp -f ${dir}/stack.yml "/etc/mothership/webserver.yml"
cp -f ${dir}/vhost.conf "/etc/mothership/templates/webserver.conf"
cp -f ${dir}/vhost.conf "/etc/mothership/vhosts-private/webserver.conf"
cp -f ${dir}/vhost.conf "/etc/mothership/vhosts-public/webserver.conf"

echo "#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

docker stack deploy --compose-file /etc/mothership/webserver.yml --with-registry-auth mothership_webserver
" > /usr/local/bin/mothership-webserver-start

echo "#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

docker stack rm mothership_webserver
" > /usr/local/bin/mothership-webserver-stop

chmod +x "/usr/local/bin/mothership-webserver-start"
chmod +x "/usr/local/bin/mothership-webserver-stop"

