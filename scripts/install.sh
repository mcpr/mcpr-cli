#!/bin/bash
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

BASE_URL=https://artifacts.filiosoft.com/mc-cli
USR_BIN=/usr/local/bin/mc

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
      URL=$BASE_URL/darwin/mc
      echo "${BLUE}Downloading binaries from $URL${COLOREND}"
      curl -sO $URL
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      URL=$BASE_URL/linux/mc
      echo "${BLUE}Downloading binaries from $URL${COLOREND}"
      curl -sO $URL
    fi
    echo "${BLUE}Moving binary to $USR_BIN${COLOREND}"
    mv mc $USR_BIN
    chmod +x $USR_BIN

    VERSION=$(mc --version)
    printf  "${GREEN}\n$VERSION has been installed!${COLOREND}"
    printf "\n${BOLD}${UNDER}Run mc --help for usage information.\n${COLOREND}"
  }

  if [ "type mc" ];
  then
    echo -n "${YELLOW}The command mc already exists on your system. Do you want to continue? (y/n)? ${COLOREND}"
    read answer
    if echo "$answer" | grep -iq "^y" ;then
      installMc
    else
      echo "${RED}Install canceled.${COLOREND}"
      exit
    fi
  else
    installMc
  fi
}


# wrapped up in a function so that we have some protection against only getting
# half the file during "curl | sh"

do_install
