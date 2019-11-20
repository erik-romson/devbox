FROM ubuntu:19.04

EXPOSE 22 7200 7777 8080 9090 3000

# Env config
ENV TERM=xterm-256color
ENV DEBIAN_FRONTEND=noninteractive

RUN chown root:root /tmp && chmod ugo+rwXt /tmp

RUN apt-get clean && \
    apt-get update && \
    apt-get install -y \
        apt-transport-https \
        apt-utils \
        ca-certificates \
        gnupg

#=============================================
# Do not exclude man pages & other docs.
# Base image is minimized for server usage.
#=============================================
RUN rm /etc/dpkg/dpkg.cfg.d/excludes && \
    apt-get update && \
    dpkg -l | grep ^ii | cut -d' ' -f3 | xargs apt-get install -y --reinstall && \
    rm -f /etc/update-motd.d/60-unminimize /etc/update-motd.d/10-help-text && \
    yes | unminimize

#=============================================
# Misc libs and tools
#=============================================
RUN apt-get install -y libgtk2.0-0 libcanberra-gtk-module libxext-dev libxrender-dev libxtst-dev xclip man nano vim software-properties-common tmux htop dos2unix mc gnome-keyring figlet jq strace atop rpm python-actdiag python-blockdiag python-seqdiag python-nwdiag graphviz inotify-tools pv xmlstarlet xmldiff q-text-as-data m4 tree silversearcher-ag libxml2-utils libwebsockets-dev

#=============================================
# Networking tools
#=============================================
RUN apt-get install -qqy curl telnet tcpdump nmap iputils-ping traceroute whois net-tools dnsutils netcat lsof ngrep sshfs cifs-utils

#=============================================
# Add sudo
#=============================================
RUN apt-get install -y cifs-utils sudo && \
    sed -i 's/sudo.*ALL=(ALL:ALL) ALL/sudo   ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

#=============================================
# SSHD
#=============================================
RUN apt-get install -y openssh-server && \
    sed -i -e s/prohibit-password/yes/ /etc/ssh/sshd_config

#=============================================
# GIT
#=============================================
RUN apt-get -y install git bash-completion git-flow gitk tig

#=============================================
# Terminal emulators
#=============================================
RUN apt-get install -y konsole

#=============================================
# Firefox
#=============================================
ARG FIREFOX_VERSION=70.0.1

RUN apt-get -y install bzip2 dbus-x11 && \
    apt-get -qqy --no-install-recommends install firefox && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* && \
    wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 && \
    apt-get -y purge firefox && \
    rm -rf /opt/firefox && \
    tar -C /opt -xjf /tmp/firefox.tar.bz2 && \
    rm /tmp/firefox.tar.bz2 && \
    mv /opt/firefox /opt/firefox-$FIREFOX_VERSION && \
    ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox

#=============================================
# Docker-ce, allow running docker in docker
#=============================================

RUN apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu disco stable" && \
    apt-get update && \
    apt-get install -y  docker-ce

#=============================================
# Timezone and locale
#=============================================
ENV TZ=Europe/Oslo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install -y locales tzdata && \
    locale-gen nb_NO.UTF-8 && \
    dpkg-reconfigure -f noninteractive tzdata

RUN wget -nv https://packagecloud.io/AtomEditor/atom/gpgkey -O /tmp/AtomEditor_atom.pub.gpg \
    && wget -nv https://dl-ssl.google.com/linux/linux_signing_key.pub -O /tmp/google.pub.gpg \
    && wget -nv https://download.docker.com/linux/ubuntu/gpg -O /tmp/docker.pub.gpg

RUN apt-key add /tmp/google.pub.gpg \
    && apt-key add /tmp/docker.pub.gpg \
    && apt-get clean && apt-get update \
    && rm /tmp/*.pub.gpg

#=============================================
# Update CA certificates
#=============================================
RUN update-ca-certificates

#=============================================
# Setup key chain for Git credentials
#=============================================
RUN apt-get install -y build-essential libglib2.0-dev libsecret-1-0 libsecret-1-dev && \
    cd /usr/share/doc/git/contrib/credential/libsecret && \
    make

#=============================================
# Fonts
#=============================================
RUN fc-cache -fv && \
    apt-get install -y font-manager

#=============================================
# Samba
#=============================================
RUN apt-get install -y samba

#=============================================
# Build and install ttyd
#=============================================
RUN apt-get install -y cmake g++ pkg-config git vim-common libwebsockets-dev libjson-c-dev libssl-dev \
    && cd /tmp \
    && git clone https://github.com/tsl0922/ttyd.git \
    && cd ttyd && mkdir build && cd build \
    && cmake .. \
    && make && make install

#=============================================
# Misc tools
#=============================================
#RUN add-apt-repository -y ppa:x4121/ripgrep && apt-get -y install ripgrep
RUN curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb && sudo dpkg -i ripgrep_11.0.2_amd64.deb
RUN cd /tmp && git clone --depth 1 https://github.com/junegunn/fzf.git && /tmp/fzf/install --bin && cp /tmp/fzf/bin/fzf /usr/bin/fzf
RUN apt-get install -y most tig

#=============================================
# Set root pwd
#=============================================
RUN echo "root:root" | chpasswd

#=============================================
# Copy and update misc config
#=============================================

COPY devbox-disk /

#=============================================
# Post process copied files
#=============================================
RUN chmod go-w /usr /usr/bin && find /usr/bin/ -name "*" -exec chmod a+x {} \;
RUN /usr/bin/config-append
RUN rm -rf /tmp/*

#=============================================
# Bootstrap image
#=============================================
ENTRYPOINT bash -c /usr/bin/container-init.sh
