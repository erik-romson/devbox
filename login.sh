#!/bin/bash
source container-props.ini

# Make sure user is created in docker image
docker exec -i $CONTAINER /bin/bash -c "[ ! -e /home/$USER ] &&  sleep 2"
docker exec --user $USER -t -i $CONTAINER bash -c 'pwd && /usr/bin/ttyd-boot.sh'
