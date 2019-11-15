# About devbox

Devbox is a docker image providing a full stack of tools for Java development. This devbox image can be used as is or can function as a base image if you require a more tailed setup for you project.

Devbox is based on Ubuntu 18.04 and includes what you need to run X11 client applications.

# Software included
The following software is included in the base image:

### Tools for software development

* Jetbrains IDEA
* OpenJDK
* Git
* Maven
* Docker

Additional tools supporting development: gitk, tig, python, chrome, graphviz, xmlstarlet, curl, tcpdump, nmap, netcat, lsof, ngrep, jfrog, strace

### Shell
Devbox includes both bash and zsh with an number of preconfigured settings 

### Other linux tools
Other tools: man, nano, vim, atom, gedit, tmux, htop, atop, mc, jq ssh, pv, xmldiff, sshfs, double commander, gnome-terminal, xterm

For the full list of included sw, se the [Dockerfile](Dockerfile)

# Bootstrap scripts
The following linux scripts are included for devbox management:



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

`browser-daemon.sh`
: Starts a netcat deamon on the docker host in order to run associate web links in the devbox docker image with the default browser on the docker host (typically Windows 10)


# Running devbox
When starting devbox with the `start.sh` script, the docker persistent volume `home` directory is mounted to `/home`. If the volume does not exist, it is created. A new linux user is then created and given `/home/<username>` as home directory. The user is set up with key-based ssh-authentication (username=pw for fallback). 

The exposed ports in devbox image are bound to 127.0.0.2 on the host, eg. 127.0.0.2:22 for sshd. It is recommended to name 127.0.0.2 to devbox is the `/etc/hosts` file on the docker host so logging in to devbox can be done by name: `ssh devbox`.

## Backup
All persisten project and user files are stored in the presistent docker volume `home`. It is recommended that you occationally make a backup of this content using the script `/usr/bin/devback.sh`. This backup script creates a tar.gz of the entire persistent volume (excluding all */target/* and /.m2/*) and stores it on the host (/mnt/c/devbox-back-data.tar.gz).

# Devbox as base image for a project spesific dev image
Devbox can be used as base image for a project customized development image. The recommended way to do this is to create a new docker project and copy all the scripts from the base image. Create a new Dockerfile that extends the base image and add project spesific stuff:

```
FROM artifactory.statnett.no/registry/statnett/devbox:latest

#=============================================
# Exposed ports will automatically be bound 
# to 127.0.0.2 when running the image
#=============================================
EXPOSE 22 8080 

#=============================================
# Copy files into the image
#=============================================
COPY devbox /

#=============================================
# More project stuff
#=============================================

.
.
.
    
#=============================================
# Post process copied files
#=============================================
RUN find /etc /root /usr -name *_append | sed -e s/_append// | xargs -iFILE sh -c "echo Appending FILE ...;cat FILE_append >> FILE;rm FILE_append" 

```
The project spesific settings (image name, ip, etc.) are defined in the config file `container-props.ini`. This file is used by all the scripts in order for these to be reusable accross projects unchagned.


Se [ois-devbox](https://gitlab.statnett.no/ois/docker/ois-devbox) for an example of a project specialized image.

## Building the image
The image can be build locally by the `build.sh` script. To ru a locally build script, run `start.sh -l`.

