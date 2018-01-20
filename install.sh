#!/usr/bin/env bash

docker network create --attachable -d overlay mothership

mkdir -p /etc/mothership/templates
mkdir -p /etc/mothership/vhosts-public
mkdir -p /etc/mothership/vhosts-private
mkdir -p /etc/mothership/vpn
