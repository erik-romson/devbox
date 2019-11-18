# About devbox

Devbox is an experimental image to be used as base image for development environments needing GUI. To serve this purpose, 
the base images includes the full stack needed to run X11 client applications. You still need a X11 server. If you are 
using Windows 10, we recommend [VcXsrv](https://sourceforge.net/projects/vcxsrv/). The most stable version we have found
is [version 1.19.5.1](https://sourceforge.net/projects/vcxsrv/files/vcxsrv/1.19.5.1/).
  
Devbox is based on Ubuntu 19.04 and includes what you need to run X11 client applications.

# Software included
The following software is included in the base image:

### Tools for software development

Tools supporting development: git, gitk, tig, python, firefox, curl, tcpdump, nmap, netcat, lsof, ngrep, strace

### Other linux tools
Other tools: man, nano, vim, tmux, htop, atop, mc, jq ssh, pv, xmldiff, sshfs, konsole, xterm

For the full list of included sw, se the [Dockerfile](Dockerfile)

# Simple Quick Start
If you just wat to try it out, pull and start the image with the following docker command:

    docker run --privileged --rm -d -it -h devbox -p 127.0.0.2:22:22 -p 127.0.0.2:8080:8080 -p 127.0.0.2:7777:7777 --add-host=pc:10.0.75.1 -e PORTS="22 7777 8080 9090" -e DEVBOXUSER=yourusername -v /var/run/docker.sock:/var/run/docker.sock -v /c:/mnt/c:consistent -v devbox-home:/home --name devbox docker.pkg.github.com/oysteinlunde/devbox/devbox:latest

Then open a web tty in you browser at the address [http://127.0.0.2:7777](http://127.0.0.2:7777). If you have a X11 server 
on your host, you can start  `firefox` or `konsole` to verify that X11 is working. 

# Bootstrap scripts
The following linux scripts are included for devbox management (on windows these require the installation of 
[WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10)):

`start.sh`
: Download devbox docker image, start a new container and log in via ssh

`stop.sh`
: Stops the devbox container

`restart.sh`
: Restarts the devbox container

`init-ssh.sh`
: Set up keybased auth for the devbox container. This script is triggered by the start script.

`build.sh`
: Builds the devbox docker imgage locally.

`init-wsl.sh`
: Bootstrap script for initiating docker-cd in Windows Service Layer (WSL on Win10) 

# Running devbox
When starting devbox with the `start.sh` script, the docker persistent volume `devbox-home` directory is mounted to `/home`. 
If the volume does not exist, it is created. A new linux user is then created and given `/home/<username>` as home directory. 
The user is set up with key-based ssh-authentication (username=pw for fallback). 

The exposed ports in devbox image are bound to 127.0.0.2 on the host, eg. 127.0.0.2:22 for sshd. It is recommended to 
name 127.0.0.2 to devbox is the `/etc/hosts` file on the docker host so logging in to devbox can be done by name: `ssh devbox`.

## Backup
All persisten project and user files are stored in the presistent docker volume `devbox-home`. It is recommended that you 
occasionally take a backup of this content using the script `/usr/bin/devback.sh`. This backup script creates a tar.gz 
of the entire persistent volume (excluding all */target/* and /.m2/*) and stores it on the host (/mnt/c/devbox-back-data.tar.gz).

# Devbox as base image for a project spesific dev image
The primary purpose of this image is to be used as a base image for a customized development image that includes the full
stack off tools needed for development, including graphical IDEs like IntelliJ or Ecliple. The recommended way to do this is to 
fork this project and use devbox-base as parent image. Create a new Dockerfile that extends the base 
image and add project spesific stuff:

```
FROM docker.pkg.github.com/oysteinlunde/devbox/devbox-base:latest

#=============================================
# Exposed ports will automatically be bound 
# to 127.0.0.2 when running the image
#=============================================
EXPOSE 22 8080 

#=============================================
# Copy files into the image
#=============================================
COPY devbox-disk /

#=============================================
# More project stuff
#=============================================

.
.
.
    
#=============================================
# Post process copied files
#=============================================
RUN /usr/bin/config-append 

```
The project spesific settings (image name, ip, etc.) are defined in the config file `container-props.ini`. This file is used by all the scripts in order for these to be reusable accross projects unchagned.

## Building the image
The image can be build locally by the `build.sh` script. To run a locally build script, run `start.sh -l`.

