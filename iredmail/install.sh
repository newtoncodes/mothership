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

docker volume create iredmail_vmail > /dev/null
docker volume create iredmail_clamav > /dev/null
docker volume create iredmail_mysql > /dev/null

docker run --privileged --rm -p 8881:80 -p 8882:443 \
    -e "DOMAIN=$domain" \
    -e "HOSTNAME=$hostname" \
    -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
    -e "POSTMASTER_PASSWORD=$POSTMASTER_PASSWORD" \
    -e "IREDAPD_PLUGINS=['reject_null_sender', 'reject_sender_login_mismatch', 'greylisting', 'throttle', 'amavisd_wblist', 'sql_alias_access_policy']" \
    -v iredmail_mysql:/var/lib/mysql \
    -v iredmail_vmail:/var/vmail \
    -v iredmail_clamav:/var/lib/clamav \
    --name=iredmail_tmp \
newtoncodes/iredmail:0.9.7

id=$(docker ps | grep iredmail_tmp | awk '{print $1;}')
