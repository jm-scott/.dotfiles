#!/bin/bash
SCRIPT_PATH=$(dirname $(realpath -s $0))
regex=".!(|.|git|*.swp)"
shopt -s extglob
cd $SCRIPT_PATH
for entry in $regex
do
	# Remove current dotfile in home directory
	if [[ -f "${HOME}/$entry" || -L "${HOME}/$entry" ]]; then
		rm -f "${HOME}/$entry"
		echo "Found pre-existing entry for: $entry" 
	fi
	# Copy local dotfile to home directory
	ln -s $SCRIPT_PATH/$entry ${HOME}/$entry
	#chmod 666 $SCRIPT_PATH/$entry
	echo "Added $entry"
done
exit 0
