#!/bin/bash

function createUser() {
    NEWUSER=$1
    echo Create new user $NEWUSER
    useradd -ms /bin/bash $NEWUSER &> /dev/null
    echo "$NEWUSER:$NEWUSER" | chpasswd
    chown -R $NEWUSER:$NEWUSER /home/$NEWUSER
    usermod -a -G docker,sudo $NEWUSER
    echo "$NEWUSER   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
    echo "Generating ssh keys ... "
    ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
    mv -f /home/$NEWUSER/.bashrc.devbox /home/$NEWUSER/.bashrc
}

echo Running init script
echo User is $DEVBOXUSER
id -u $DEVBOXUSER || createUser $DEVBOXUSER
