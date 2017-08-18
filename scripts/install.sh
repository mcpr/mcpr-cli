#!/bin/bash
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

BASE_URL=https://artifacts.filiosoft.com/mcpr-cli
USR_BIN=/usr/local/bin/mcpr

# Colors
COLOREND=$(tput sgr0)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
UNDER=$(tput smul)
BOLD=$(tput bold)

do_install (){
  echo "Installing:"

  cat <<-EOF
  ${GREEN}
    __  __  ____       ____ _     ___
  |  \/  |/ ___|     / ___| |   |_ _|
  | |\/| | |   _____| |   | |    | |
  | |  | | |__|_____| |___| |___ | |
  |_|  |_|\____|     \____|_____|___|
  ${COLOREND}
	EOF

  sleep 3

  echo "${BLUE}You are running $(uname) $(uname -m)${COLOREND}"

  installMc () {
    if [ "$(uname)" == "Darwin" ]; then
      URL=$BASE_URL/darwin/mcpr
      echo "${BLUE}Downloading binaries from $URL${COLOREND}"
      curl -sO $URL
    elif [ "$(lsb_release -is)" == "Ubuntu" ]; then
      curl -sL https://apt.filiosoft.com/setup | sudo -E bash -
      sudo apt-get install mcpr-cli -y
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      URL=$BASE_URL/linux/mcpr
      echo "${BLUE}Downloading binaries from $URL${COLOREND}"
      curl -sO $URL
    fi

    if [ "$(lsb_release -is)" == "Ubuntu" ]; then
      echo "Setup complete..."
    else
      echo "${BLUE}Moving binary to $USR_BIN${COLOREND}"
      mv mcpr $USR_BIN
      chmod +x $USR_BIN
    fi

    VERSION=$(mcpr --version)
    printf  "${GREEN}\n$VERSION has been installed!${COLOREND}"
    printf "\n${BOLD}${UNDER}Run mcpr --help for usage information.\n${COLOREND}"
  }

  COMMAND=mcpr
  if [ -x "$(command -v mcpr)" ];
  then
    echo "${YELLOW}The command mcpr already exists on your system. If you already have MCPR-CLI installed, please run \"curl -sSL http://fsft.us/mcpr-cli-update | sudo bash\" ${COLOREND}"
    echo "${RED}Install canceled.${COLOREND}"
    exit
  else
    installMc
  fi
}


# wrapped up in a function so that we have some protection against only getting
# half the file during "curl | bash"
do_install
