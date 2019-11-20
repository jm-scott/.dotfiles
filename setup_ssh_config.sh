#!/bin/bash
SCRIPT_PATH=$(dirname $(realpath -s $0))
ssh_location="${HOME}/.ssh"
config_location=$SCRIPT_PATH/ssh_config

if [[ ! -d $ssh_location ]]; then
	mkdir $ssh_location && cp ssh_config $ssh_location/config
fi

if [[ -f "$ssh_location/config" || -L "$ssh_location/config" ]]; then
    echo "SSH Config file already exists."
	read -p "Overwrite? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
	rm "$ssh_location/config"
fi

chmod 600 $config_location
ln -s $config_location $ssh_location/config
exit 0
