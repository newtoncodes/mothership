#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${dir}/../src/lib.sh

set -e

passwordXwiki=$(pwgen -1 32)
install xwiki ${passwordXwiki}

docker volume create mothership_xwiki_data > /dev/null
docker volume create mothership_xwiki_mysql > /dev/null

docker run --rm -d -v mothership_xwiki_mysql:/var/lib/mysql --name xwiki_mysql_run newtoncodes/mysql:5.7 > /dev/null
id=$(docker ps | grep xwiki_mysql_run | awk '{print $1;}')

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

docker exec ${id} mysql -uroot -p${passwordRoot} -e "CREATE DATABASE xwiki COLLATE 'utf8_general_ci';
CREATE USER 'xwiki'@'%' IDENTIFIED BY '$passwordXwiki';
GRANT ALL PRIVILEGES ON xwiki.* TO 'xwiki'@'%';
FLUSH PRIVILEGES;" 2> /dev/null

set +e

ready=$(docker exec ${id} mysql -uxwiki -p${passwordXwiki} -e "SHOW DATABASES;" 2> /dev/null | grep xwiki)
if [ "$ready" != "xwiki" ]; then
    docker stop ${id} > /dev/null
    echo >&2 "Failed to create xwiki database and user."
    exit 1
fi

docker stop ${id} > /dev/null

echo ""
echo "Root: $passwordRoot"
echo "Xwiki: $passwordXwiki"
echo ""
