#!/bin/bash
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

BASE_URL=https://get.mcpr.io/artifacts
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
   __  __  ____ ____  ____        ____ _     ___ 
  |  \/  |/ ___|  _ \|  _ \      / ___| |   |_ _|
  | |\/| | |   | |_) | |_) |____| |   | |    | | 
  | |  | | |___|  __/|  _ <_____| |___| |___ | | 
  |_|  |_|\____|_|   |_| \_\     \____|_____|___|
  ${COLOREND}
	EOF

  sleep 3

  echo "${BLUE}You are running $(uname) $(uname -m)${COLOREND}"

  installMc () {
    if [ "$(uname)" == "Darwin" ]; then
      URL=$BASE_URL/darwin/mcpr-stable
      echo "${BLUE}Downloading binaries from $URL${COLOREND}"
      curl -sO $URL
    elif [ -n "$(command -v apt-get)" ]; then
      curl -o- -sL https://get.mcpr.io/debian/setup | bash -s -- --nightly
      apt-get install mcpr-cli -y
    #elif [ -n "$(command -v rpm)" ]; then
    #  wget https://get.mcpr.io/rpm/mcpr.repo -O /etc/yum.repos.d/mcpr.repo
    #  yum install mcpr-cli -y
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      URL=$BASE_URL/linux/mcpr-stable
      echo "${BLUE}Downloading binaries from $URL${COLOREND}"
      curl -sO $URL
    else 
      echo "${RED}Your OS doesn't seem to be supported.${COLOREND}"
      exit 1
    fi

    if [ -n "$(command -v apt-get)" ]; then
      echo "Setup complete..."
    else
      echo "${BLUE}Moving binary to $USR_BIN${COLOREND}"
      mv mcpr-stable $USR_BIN
      chmod +x $USR_BIN
    fi

    VERSION=$($USR_BIN --version)
    printf  "${GREEN}\n$VERSION has been installed!${COLOREND}"
    printf "\n${BOLD}${UNDER}Run mcpr --help for usage information.\n${COLOREND}"
  }

  if [ -x "$(command -v mcpr)" ];
  then
    echo "${YELLOW}The command mcpr already exists on your system.${COLOREND}"
    echo "${RED}Install canceled.${COLOREND}"
    exit
  else
    installMc
  fi
}


# wrapped up in a function so that we have some protection against only getting
# half the file during "curl | bash"
do_install
