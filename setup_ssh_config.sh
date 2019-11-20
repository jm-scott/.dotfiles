#!/bin/bash

ssh_location="${HOME}/.ssh"

if [[ ! -d $ssh_location ]]; then
	mkdir $ssh_location && cp ssh_config "$ssh_location/config"
fi

if [[ -f "$ssh_location/config" ]]; then
    echo "SSH Config file already exists."
	read -p "Overwrite? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
fi

cp ssh_config "$ssh_location/config"
exit 0
