#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${dir}/../src/lib.sh

set -e

install iredmail

echo "Mail domain: "
read domain;

echo "Mail hostname: "
read hostname;

sed -i "s/- DOMAIN=.*/- DOMAIN=$domain/" /etc/mothership/iredmail.yml
sed -i "s/- HOSTNAME=.*/- HOSTNAME=$hostname/" /etc/mothership/iredmail.yml

MYSQL_ROOT_PASSWORD=$(pwgen -1 32)
POSTMASTER_PASSWORD=$(pwgen -1 32)

docker volume create mothership_iredmail_vmail > /dev/null
docker volume create mothership_iredmail_clamav > /dev/null
docker volume create mothership_iredmail_mysql > /dev/null

docker run --privileged --rm -d -p 8881:80 -p 8882:443 \
    -e "DOMAIN=$domain" \
    -e "HOSTNAME=$hostname" \
    -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
    -e "POSTMASTER_PASSWORD=$POSTMASTER_PASSWORD" \
    -e "IREDAPD_PLUGINS=['reject_null_sender', 'reject_sender_login_mismatch', 'greylisting', 'throttle', 'amavisd_wblist', 'sql_alias_access_policy']" \
    -v mothership_iredmail_mysql:/var/lib/mysql \
    -v mothership_iredmail_vmail:/var/vmail \
    -v mothership_iredmail_clamav:/var/lib/clamav \
    --name=iredmail_tmp \
newtoncodes/iredmail:0.9.7

id=$(docker ps | grep iredmail_tmp | awk '{print $1;}')

set +e

echo "Iredmail first start in progress..."
ready=

for i in {30..0}; do
    sleep 10

    if [ "$ready" != "" ]; then break; fi

    ready=$(docker logs ${id} 2> /dev/null | grep "Self checking every 3600 seconds")
done

if [ "$i" = 0 ]; then
    docker stop ${id} > /dev/null
    echo >&2 "Iredmail init process failed."
    exit 1
fi

echo "Iredmail started ok."

echo ""
echo "Root: $MYSQL_ROOT_PASSWORD"
echo "Postmaster: $POSTMASTER_PASSWORD"
echo ""

docker logs ${id}
docker stop ${id} > /dev/null
