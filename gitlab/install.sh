#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${dir}/../src/lib.sh

set -e

install gitlab

docker volume create mothership_gitlab_config > /dev/null
docker volume create mothership_gitlab_log > /dev/null
docker volume create mothership_gitlab_data > /dev/null
