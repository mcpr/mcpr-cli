#!/bin/bash
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

BASE_URL=https://artifacts.filiosoft.com/mc-cli

if [ "$(uname)" == "Darwin" ]; then
    echo "Darwin"
    curl -O $BASE_URL/darwin/mc
    mv mc /usr/local/bin
    chmod +x /usr/local/bin/mc
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Linux"
    curl -O $BASE_URL/linux/mc
    mv mc /usr/local/bin
    chmod +x /usr/local/bin/mc
fi

echo "MC-CLI has been installed!"
