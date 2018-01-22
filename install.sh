#!/usr/bin/env bash

set -e

#docker network create --attachable -d overlay mothership

mkdir -p /etc/mothership/apps
mkdir -p /etc/mothership/snet
mkdir -p /etc/mothership/certs
mkdir -p /etc/mothership/vhosts-tpl
mkdir -p /etc/mothership/vhosts-public
mkdir -p /etc/mothership/vhosts-private

echo "#!/usr/bin/env bash

docker run \\
    --detach \\
    --network=mothership \\
    --name mothership_snet \\
    --hostname snet \\
    --restart always \\
    --cap-add=NET_ADMIN \\
    --device=/dev/net/tun \\
    -v /etc/mothership/snet:/etc/snet \\
    -e \"PORTS=80:nginx_private:80 443:nginx_private:443 22:gitlab:22\" \\
newtoncodes/snet:1.0.0

" > /usr/local/bin/mothership-snet-start

echo "#!/usr/bin/env bash

docker stop $(docker ps -aq --filter=name=mothership_snet)
" > /usr/local/bin/mothership-snet-stop

chmod +x "/usr/local/bin/mothership-snet-start"
chmod +x "/usr/local/bin/mothership-snet-stop"
