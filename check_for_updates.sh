#!/bin/bash
cd ~/.dotfiles/
git fetch

if [$LOCAL = $BASE]; then
	echo "Your dotfiles repo is out of date."
	echo "Run ./~/.dotfiles/update_dotfiles.sh to update."
fi
