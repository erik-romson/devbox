#!/bin/bash
source container-props.ini 

echo Building docker image $CONTAINER
docker build -t $CONTAINER .