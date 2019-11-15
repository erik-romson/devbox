#!/usr/bin/env bash
chmod a+x /etc/update-motd.d/*
/etc/init.d/ssh start
export DEVBOXUSER=${DEVBOXUSER:-user}
echo "$PORTS" > /etc/docker.ports
bash -c /usr/bin/create-user.sh  &> /var/log/create-user.log
chmod a+x /usr/bin/dev-browser
ln -sf /usr/bin/dev-browser /usr/bin/browse
if [[ -e /var/run/docker.sock ]]; then
    chmod a+rwx /var/run/docker.sock
fi

# Start ttyd daemon
cd /home/$DEVBOXUSER
sudo -u "$DEVBOXUSER" -H /usr/bin/ttyd -p 7777 /usr/bin/ttyd-boot.sh

# Safety net in case ttyd is stoped
while true; do sleep 42d; done


