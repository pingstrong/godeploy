#!/bin/sh

docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q) && docker rmi $(docker images -q)

docker rmi `docker images | grep  '<none>' | awk '{print $3}'`