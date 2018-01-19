#!/usr/bin/env bash

dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
source ${dir}/../src/lib.sh

set -e

install registry


docker volume create mothership_registry_data > /dev/null

