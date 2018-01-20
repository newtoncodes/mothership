#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${dir}/../src/lib.sh

set -e

mkdir -p /etc/mothership/registry-auth

install registry

docker volume create mothership_registry_data > /dev/null

echo "#!/usr/bin/env bash

docker run \\
  --entrypoint htpasswd \\
  registry:2 -Bbn \${1} \${2} >> /etc/mothership/registry-auth/htpasswd

sed -i -n '/./,/^$/p' /etc/mothership/registry-auth/htpasswd
sed -i -n '/./,/^$/p' /etc/mothership/registry-auth/htpasswd
" > /usr/local/bin/mothership-registry-user-add

echo "#!/usr/bin/env bash

sed -i \"s@^\${1}:.*@@\" /etc/mothership/registry-auth/htpasswd
sed -i -n '/./,/^$/p' /etc/mothership/registry-auth/htpasswd
sed -i -n '/./,/^$/p' /etc/mothership/registry-auth/htpasswd
" > /usr/local/bin/mothership-registry-user-remove

chmod +x /usr/local/bin/mothership-registry-user-add
chmod +x /usr/local/bin/mothership-registry-user-remove
