#!/usr/bin/env bash

docker volume create gitlab_config
docker volume create gitlab_log
docker volume create gitlab_data

docker network create --attachable gitlab
