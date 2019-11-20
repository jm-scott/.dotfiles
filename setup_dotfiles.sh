#!/bin/bash
for entry in .*
do
	# Skip current and parent directory
	if [[ "$entry" == "." ]] || [[ "$entry" == ".." ]]; then
		continue
	fi
	# Remove current dotfile in home directory
	if [[ -f "~/$entry" ]]; then
		rm -f ~/$entry
	fi
	# Copy local dotfile to home directory
	ln -s $PWD/$entry ~/$entry
	echo "$entry"
done
exit 0
