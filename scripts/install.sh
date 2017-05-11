#!/bin/bash
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

BASE_URL=https://artifacts.filiosoft.com/mc-cli

USR_BIN=/usr/local/bin/mc

echo "You are running $(uname)"

function installMc {
  if [ "$(uname)" == "Darwin" ]; then
    URL=$BASE_URL/darwin/mc
    echo "Downloading binaries from $URL"
    curl -sO $URL
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    URL=$BASE_URL/linux/mc
    echo "Downloading binary from $URL"
    curl -sO $URL
  fi
  mv mc $USR_BIN
  chmod +x $USR_BIN

  VERSION=$(mc --version)
  echo "$VERSION has been installed!"
  echo "Run mc --help for usage information."
}

if [ -e "$USR_BIN" ]
then
  echo "A file at $USR_BIN already exists."
  echo -n "Do you want to overwrite it? (y/n)? "
  read answer
  if echo "$answer" | grep -iq "^y" ;then
    installMc
  else
    exit
  fi
else
  installMc
fi
