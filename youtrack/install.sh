#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${dir}/../src/lib.sh

set -e

install youtrack


docker volume create mothership_youtrack_data > /dev/null
docker volume create mothership_youtrack_backup > /dev/null
