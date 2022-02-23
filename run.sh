#!/usr/bin/env bash

# This script is only used to run the dockercontainer built by the makefile and mount the pwd
echo "[Script] Using docker: $(docker -v)"
docker run --volume "$(pwd):/home/oreo-user/data" alpine-oreo:latest "/home/oreo-user/data/$@"
