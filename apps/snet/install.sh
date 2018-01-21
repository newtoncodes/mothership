#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

mkdir -p /etc/mothership/vpn


echo "#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

docker run \
    --detach \
    --rm \
    --network=mothership \
    --name mothership_snet \
    --hostname snet \
    --restart always \
    --cap-add=NET_ADMIN \
    --device=/dev/net/tun \
    -v /etc/mothership/vpn:/etc/snet \
    -e PORTS=80:nginx_private:80 443:nginx_private:443 22:gitlab:22
newtoncodes/snet:1.0.0

" > /usr/local/bin/mothership-snet-start

echo "#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

docker stop $(docker ps -aq --filter=name=mothership_snet)
" > /usr/local/bin/mothership-snet-stop

chmod +x "/usr/local/bin/mothership-snet-start"
chmod +x "/usr/local/bin/mothership-snet-stop"
