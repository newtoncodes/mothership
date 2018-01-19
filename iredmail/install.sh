#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

echo "Domain: "
read domain;

echo "Hostname: "
read hostname;

MYSQL_ROOT_PASSWORD=$(pwgen -1 32)
POSTMASTER_PASSWORD=$(pwgen -1 32)

docker volume create iredmail_vmail > /dev/null
docker volume create iredmail_clamav > /dev/null
docker volume create iredmail_mysql > /dev/null

docker network create --attachable iredmail > /dev/null

docker run --privileged --rm -p 8881:80 -p 8882:443 \
           -e "DOMAIN=$domain"
           -e "HOSTNAME=$hostname" \
           -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
           -e "POSTMASTER_PASSWORD=$POSTMASTER_PASSWORD" \
           -e "IREDAPD_PLUGINS=['reject_null_sender', 'reject_sender_login_mismatch', 'greylisting', 'throttle', 'amavisd_wblist', 'sql_alias_access_policy']" \
           -v iredmail_mysql:/var/lib/mysql \
           -v iredmail_vmail:/var/vmail \
           -v iredmail_clamav:/var/lib/clamav \
           --name=iredmail_tmp lejmr/iredmail:mysql-latest

id=$(docker ps | grep iredmail_tmp | awk '{print $1;}')

sed -i "s/- DOMAIN=.*/- DOMAIN=$domain/" ${dir}/stack.yml
sed -i "s/- HOSTNAME=.*/- HOSTNAME=$hostname/" ${dir}/stack.yml

