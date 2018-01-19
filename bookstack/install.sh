#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

set -e

mkdir -p /etc/mothership/bookstack/vpn
cp -f ${dir}/vhost.conf /etc/mothership/bookstack/vhost.conf

passwordBookstack=$(pwgen -1 32)

docker volume create bookstack_uploads > /dev/null
docker volume create bookstack_storage > /dev/null
docker volume create bookstack_mysql > /dev/null
docker network create --attachable bookstack > /dev/null

docker run --rm -d -v bookstack_mysql:/var/lib/mysql --name bookstack_mysql_run newtoncodes/mysql:5.7 > /dev/null
id=$(docker ps | grep bookstack_mysql_run | awk '{print $1;}')

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

docker exec ${id} mysql -uroot -p${passwordRoot} -e "CREATE DATABASE bookstack COLLATE 'utf8_general_ci';
CREATE USER 'bookstack'@'%' IDENTIFIED BY '$passwordBookstack';
GRANT ALL PRIVILEGES ON bookstack.* TO 'bookstack'@'%';
FLUSH PRIVILEGES;" 2> /dev/null

set +e

ready=$(docker exec ${id} mysql -ubookstack -p${passwordBookstack} -e "SHOW DATABASES;" 2> /dev/null | grep bookstack)
if [ "$ready" != "bookstack" ]; then
    docker stop ${id} > /dev/null
    echo >&2 "Failed to create bookstack database and user."
    exit 1
fi

docker stop ${id} > /dev/null

echo ""
echo "Root: $passwordRoot"
echo "Bookstack: $passwordBookstack"
echo "Admin: admin@admin.com : password"
echo ""
