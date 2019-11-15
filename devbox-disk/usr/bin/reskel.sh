#!/bin/bash
#
# Re-apply the /etc/skel template files to user local copy
#

cd $HOME

files=($(find /etc/skel/ -type f -not -path "*.oh-my-zsh*"  2>&1 | grep -v "Permission denied" |  sed -e s#/etc/skel/##  ))


update() {
	read -p "$2. Oppdater [j/N/d] ? " a
	if [ "$a" = "j" ]; then
                BAKDIR=$HOME/.local/.backup
		echo "  Oppdaterer $1. Backup av gammel fil legges i $BAKDIR/$1"
                mkdir -p $BAKDIR
		mv $1 $BAKDIR
                cp /etc/skel/$1 $1
	fi
		
        if [ "$a" = "d" ]; then
                echo "-------------------------------------------------------------------"
                echo Delta mellom skel og lokal kopi. Reskel vil erstatte rødt med grønt.
                echo "-------------------------------------------------------------------"
 		diff --color -N $1 /etc/skel/$1
                echo "-------------------------------------------------------------------"
		update "$1" "$2"
	fi
}

for file in "${files[@]}";
do
	if [[ ! -f "$file" ]];then
 		update "$file" "Ny fil '$file'"
		continue
	fi

	delta=$(diff "/etc/skel/$file" "$file" | wc -l)
	[ $delta -gt 0 ] && update "$file" "Filen '$file' har $delta endringer"

done
