#!/usr/bin/env bash
chmod a+x /etc/update-motd.d/*
service ssh start
service smbd start
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

TTYD_THEME='theme={"foreground": "#B6BECC","background": "#1F2126","cursor": "#6DE6F5","black": "#1E222A","boldBlack": "#1E222A","red": "#FF7B85","boldRed": "#FF7B85","green": "#C0F699","boldGreen": "#C0F699","yellow": "#FFD689","boldYellow": "#FFD689","blue": "#67BBFF","boldBlue": "#67BBFF","magenta": "#E48AFF","boldMagenta": "#E48AFF","cyan": "#6DE6F5","boldCyan": "#6DE6F5","white": "#E4EEFF","boldWhite": "#E4EEFF"}'
TTYD_FONT='fontFamily="Ubuntu Mono,Menlo For Powerline,Consolas,Liberation Mono,Menlo,Courier,monospace"'
sudo -u "$DEVBOXUSER" -H /usr/local/bin/ttyd -p 7777 -t "$TTYD_THEME" -t "$TTYD_FONT" /usr/bin/ttyd-boot.sh

# Safety net in case ttyd is stoped
while true; do sleep 42d; done
