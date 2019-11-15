#!/bin/bash

function createUser() {
    echo Create new user $1
    useradd -ms /bin/bash $1 &> /dev/null
    echo "$1:$1" | chpasswd
    chown -R $1:$1 /home/$1
    usermod -a -G docker,sudo $DEVBOXUSER
    echo "$DEVBOXUSER   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
}

echo Running init script
echo User is $DEVBOXUSER
id -u $DEVBOXUSER || createUser $DEVBOXUSER
