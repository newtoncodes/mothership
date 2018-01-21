#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${dir}/../../src/lib.sh

set -e

install ldap

docker volume create ldap_certs > /dev/null
docker volume create ldap_config > /dev/null
docker volume create ldap_data > /dev/null
