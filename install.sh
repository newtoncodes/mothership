#!/usr/bin/env bash

docker network create --attachable mothership

mkdir -p /etc/mothership/templates
mkdir -p /etc/mothership/vhosts
mkdir -p /etc/mothership/vpn
