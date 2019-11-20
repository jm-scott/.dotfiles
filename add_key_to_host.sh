#!/bin/bash

read -p "Enter user: " user

read -p "Enter hostname: " hostname

if [[! -f "${HOME}/.ssh/id_rsa.pub" ]]; then
	echo "Public key does not exist."
	exit 1
fi

cat ~/.ssh/id_rsa.pub | ssh user@hostname "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
exit 0
