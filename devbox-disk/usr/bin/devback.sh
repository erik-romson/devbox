#!/bin/bash

default=/mnt/c/devbox-back-$(date +"%Y-%m-%d_%H%M").tar.gz

if [ "--help" = "$1" -o "-h" = "$1" ]; then
	echo
	echo "Create a tar.gz backup of files in $HOME/"
	echo "Maven repo (~/.m2) and all directories matching */target, ~/.cache, ~/.local/share/Trash are excluded. External files systems mounted under $HOME are excluded."
	echo
	echo "Syntax: devback.sh [target]"
	echo "        Default target = $default"
	echo 
	exit 0
fi

target=${1:-$default}
tar -pczf $target --exclude="$HOME/.local/share/Trash" --exclude="$HOME/.cache" --exclude="$HOME/.m2" --exclude="*/target" --totals --verbose --one-file-system --exclude-backups --exclude-caches $HOME/

echo 
echo Backup file "$target" created
echo