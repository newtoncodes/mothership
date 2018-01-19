#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

echo "Domain: "
read domain;

mkdir -p /etc/mothership/nextcloud/vpn
cp -f ${dir}/vhost.conf /etc/mothership/nextcloud/vhost.conf
cp -f ${dir}/stack.yml /etc/mothership/nextcloud/stack.yml

sed -i "s/{{DOMAIN}}/$domain/" /etc/mothership/nextcloud/vhost.conf

passwordNextcloud=$(pwgen -1 32)

docker volume create nextcloud_data > /dev/null
docker volume create nextcloud_mysql > /dev/null
docker network create --attachable nextcloud > /dev/null

docker run --rm -d -v nextcloud_mysql:/var/lib/mysql --name nextcloud_mysql_run newtoncodes/mysql:5.7 > /dev/null
id=$(docker ps | grep nextcloud_mysql_run | awk '{print $1;}')

set +e

echo "MySQL init process in progress..."
passwordRoot=
ready=

for i in {30..0}; do
    sleep 1

    if [ "$passwordRoot" != "" ] && [ "$ready" != "" ]; then
        select1=$(docker exec ${id} mysql -uroot -p${passwordRoot} -e "select 1" 2> /dev/null)
        if [ "$select1" != "" ]; then break; fi
    else
        passwordRoot=$(docker logs ${id} 2> /dev/null | grep "GENERATED ROOT" | cut -d ":" -f 2 | cut -d " " -f 2)
        ready=$(docker logs ${id} 2> /dev/null | grep "MySQL is ready.")
    fi
done

if [ "$i" = 0 ]; then
    echo >&2 "MySQL init process failed."
    exit 1
fi

echo "MySQL is ready."

set -e

docker exec ${id} mysql -uroot -p${passwordRoot} -e "CREATE DATABASE nextcloud COLLATE 'utf8_general_ci';
CREATE USER 'nextcloud'@'%' IDENTIFIED BY '$passwordNextcloud';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'%';
FLUSH PRIVILEGES;" 2> /dev/null

set +e

ready=$(docker exec ${id} mysql -unextcloud -p${passwordNextcloud} -e "SHOW DATABASES;" 2> /dev/null | grep nextcloud)
if [ "$ready" != "nextcloud" ]; then
    docker stop ${id} > /dev/null
    echo >&2 "Failed to create nextcloud database and user."
    exit 1
fi

docker stop ${id} > /dev/null

echo ""
echo "Root: $passwordRoot"
echo "Nextcloud: $passwordNextcloud"
echo ""
