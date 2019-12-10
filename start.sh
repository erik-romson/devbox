#!/bin/bash
source container-props.ini

SCRIPT_FOR_USER=$USER

#echo "set CONTAINER=$CONTAINER" > $SCRIPT_DIR/cmd/container-props.cmd

if [ "$1" = "-h" ]; then
	echo "Usage: start.sh [OPTION]"
	echo
	echo "Runs the '$CONTAINER' docker container"
	echo
	echo "Options:"
	echo "   -o 	Run docker container without pulling latest version from artifactory (offline mode)"
	echo "   -l 	Run locally built docker container (using ./build.sh)"
	echo "   -h 	Print usage"
	echo
	exit 0
fi
if [ "$1" = "-l" ];then
	IMAGE=$CONTAINER:latest
	if [[ "$(docker images -q $IMAGE 2> /dev/null)" == "" ]]; then
  		echo "Docker image '$IMAGE' not found. You have to build a local image before running it."
  	else
  		echo "Using locally build image '$IMAGE'"
	fi
fi

# Map EXPOSED ports from container
for port in $PORTS
do
    PORT_MAPS="-p $DEVBOX_IP:$port:$port $PORT_MAPS"
done

# Add extra hosts to container /etc/hosts
IFS=',' HOST_LIST=($HOSTS)
for HOST_ITEM in "${HOST_LIST[@]}"
do
	HOST_MAPS="--add-host=$HOST_ITEM $HOST_MAPS"
	echo $HOST_MAPS
done
IFS=$' \t\n'

# Pull latest image from actifactory
if [ "$1" != "-o" -a "$1" != "-l" ];then
	echo "Pulling image from $IMAGE"
	docker pull $IMAGE
	source container-props.ini
fi

# Run image
#docker run --privileged --rm -d  -it -h devbox $PORT_MAPS $HOST_MAPS -e PORTS="$PORTS" -e DEVBOXUSER=$SCRIPT_FOR_USER -v /var/run/docker.sock:/var/run/docker.sock -v /c:/mnt/c:consistent  -v $HOME_VOLUME:/home --name $CONTAINER $IMAGE
docker run --privileged --rm -d  -it -h devbox $PORT_MAPS $HOST_MAPS -e PORTS="$PORTS" -e "DOCKER_HOST=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')" -e DEVBOXUSER=$SCRIPT_FOR_USER -v /var/run/docker.sock:/var/run/docker.sock   -v ~/.ssh:/home/$USER/.ssh -v $HOME_VOLUME:/home --name $CONTAINER $IMAGE

echo Starting $CONTAINER ...

docker logs $CONTAINER
docker ps
echo
echo Docker image $CONTAINER started
echo

$SCRIPT_DIR/login.sh

#docker exec --user $SCRIPT_FOR_USER -t -i devbox /usr/bin/ttyd-boot.sh

#./init-ssh.sh

#for SERVER in devbox $DEVBOX_IP
#do
#	ssh-keygen -q -f "/home/$SCRIPT_FOR_USER/.ssh/known_hosts" -R $SERVER &> /dev/null
#	ssh -o StrictHostKeyChecking=no $SERVER exit &> /dev/null
#done

#
# Logging into devbox
#
#ssh -q $DEVBOX_IP
