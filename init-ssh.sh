#!/bin/bash

source container-props.ini 

[ ! -f ~/.ssh/id_rsa.pub ] && echo "Generating ssh keys" && ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''

docker exec --user $USER  -i $CONTAINER /bin/bash -c "[ ! -f /home/$USER/.ssh/ ] && mkdir -p /home/$USER/.ssh"
docker exec --user $USER  -i $CONTAINER /bin/bash -c "[ ! -f /home/$USER/.ssh/id_rsa ] && cat > /home/$USER/.ssh/id_rsa" < ~/.ssh/id_rsa
docker exec --user $USER  -i $CONTAINER /bin/bash -c "[ ! -f /home/$USER/.ssh/id_rsa.pub ] && cat > /home/$USER/.ssh/id_rsa.pub" < ~/.ssh/id_rsa.pub
docker exec --user $USER  -i $CONTAINER /bin/bash -c "[ ! -f /home/$USER/.ssh/authorized_keys ] && cd /home/$USER/.ssh/ && ln -s id_rsa.pub authorized_keys"
docker exec --user $USER  -i $CONTAINER /bin/bash -c "chmod 600 /home/$USER/.ssh/id_rsa" 
