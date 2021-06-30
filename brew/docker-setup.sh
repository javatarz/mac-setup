#!/bin/sh

docker-machine create --driver virtualbox default

if [ $? == 1 ]; then
  # Virtual box already exists. The above command has put this on the console and therefore not echoing anything
  exit 0
fi
