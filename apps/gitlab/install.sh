#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${dir}/../../src/lib.sh

set -e

install gitlab

docker volume create gitlab_config > /dev/null
docker volume create gitlab_log > /dev/null
docker volume create gitlab_data > /dev/null
