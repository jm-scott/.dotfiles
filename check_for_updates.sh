#!/bin/bash
cd ~/.dotfiles/
git fetch

UPSTREAM=${1:-"@{u}"}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")
echo "Checking for dotfile updates"
if [ $LOCAL != $REMOTE ] && [ $LOCAL = $BASE ]; then
	echo "Your dotfiles repo is out of date."
	echo "Run ./~/.dotfiles/update_dotfiles.sh to update."
	read -p "Update dotfiles? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
	git pull
	./setup_dotfiles.sh
else
	echo "No updates found."
fi

exit 0
