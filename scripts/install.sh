#!/bin/bash
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

BASE_URL=https://artifacts.filiosoft.com/mc-cli
USR_BIN=/usr/local/bin/mc

do_install (){
  echo "Installing:"
  cat <<-EOF
    __  __  ____       ____ _     ___
  |  \/  |/ ___|     / ___| |   |_ _|
  | |\/| | |   _____| |   | |    | |
  | |  | | |__|_____| |___| |___ | |
  |_|  |_|\____|     \____|_____|___|


	EOF
  echo "You are running $(uname)"

  installMc () {
    if [ "$(uname)" == "Darwin" ]; then
      URL=$BASE_URL/darwin/mc
      echo "Downloading binaries from $URL"
      curl -sO $URL
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      URL=$BASE_URL/linux/mc
      echo "Downloading binary from $URL"
      curl -sO $URL
    fi
    echo "Moving binary to $USR_BIN"
    mv mc $USR_BIN
    chmod +x $USR_BIN

    VERSION=$(mc --version)
    printf  "\n$VERSION has been installed!"
    printf "\nRun mc --help for usage information.\n"
  }

  if [ "type mc" ];
  then
    echo -n "The command mc already exists on your system. Do you want to continue? (y/n)? "
    read answer
    if echo "$answer" | grep -iq "^y" ;then
      installMc
    else
      echo "Install canceled."
      exit
    fi
  else
    installMc
  fi
}


# wrapped up in a function so that we have some protection against only getting
# half the file during "curl | sh"

do_install
