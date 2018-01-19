#!/usr/bin/env bash

set -e

docker volume create youtrack_data > /dev/null
docker volume create youtrack_backup > /dev/null

docker network create --attachable youtrack
