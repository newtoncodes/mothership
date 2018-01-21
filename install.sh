#!/usr/bin/env bash

docker network create --attachable -d overlay mothership

mkdir -p /etc/mothership/apps
mkdir -p /etc/mothership/snet
mkdir -p /etc/mothership/vhosts-tpl
mkdir -p /etc/mothership/vhosts-public
mkdir -p /etc/mothership/vhosts-private
