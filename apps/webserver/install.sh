#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${dir}/../../src/lib.sh

set -e

mkdir -p /etc/mothership/apps
mkdir -p /etc/mothership/snet
mkdir -p /etc/mothership/certs
mkdir -p /etc/mothership/vhosts-tpl
mkdir -p /etc/mothership/vhosts-public
mkdir -p /etc/mothership/vhosts-private

checkCerts

cp -f ${dir}/stack.yml "/etc/mothership/apps/webserver.yml"
cp -f ${dir}/vhost.conf "/etc/mothership/vhosts-tpl/00-default.conf"
cp -f ${dir}/vhost.conf "/etc/mothership/vhosts-private/00-default.conf"
cp -f ${dir}/vhost.conf "/etc/mothership/vhosts-public/00-default.conf"

echo "#!/usr/bin/env bash

if [ ! -f '/etc/mothership/certs/ca.crt' ]; then
    echo 'Place the following files in /etc/mothership/certs:'
    echo '  ca.crt, server.crt, server.bundle.crt (crt + ca), server.key'
    exit 1;
fi

if [ ! -f '/etc/mothership/certs/server.crt' ]; then
    echo 'Place the following files in /etc/mothership/certs:'
    echo '  ca.crt, server.crt, server.bundle.crt (crt + ca), server.key'
    exit 1;
fi

if [ ! -f '/etc/mothership/certs/server.bundle.crt' ]; then
    echo 'Place the following files in /etc/mothership/certs:'
    echo '  ca.crt, server.crt, server.bundle.crt (crt + ca), server.key'
    exit 1;
fi

if [ ! -f '/etc/mothership/certs/server.key' ]; then
    echo 'Place the following files in /etc/mothership/certs:'
    echo '  ca.crt, server.crt, server.bundle.crt (crt + ca), server.key'
    exit 1;
fi

docker stack deploy --compose-file /etc/mothership/apps/webserver.yml --with-registry-auth webserver
" > /usr/local/bin/mothership-webserver-start

echo "#!/usr/bin/env bash

docker stack rm webserver
" > /usr/local/bin/mothership-webserver-stop

chmod +x "/usr/local/bin/mothership-webserver-start"
chmod +x "/usr/local/bin/mothership-webserver-stop"
