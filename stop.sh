#!/bin/bash
source container-props.ini 

echo Stopping docker image $CONTAINER ...
docker stop $CONTAINER

echo
echo Docker image $CONTAINER stopped
echo