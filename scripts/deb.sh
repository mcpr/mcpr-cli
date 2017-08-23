#!/bin/bash

# Script to install the Filiosoft repo onto a
# Debian or Ubuntu system.
#
# Run as root or insert `sudo -E` before `bash`:
#
# curl -sL https://apt.filiosoft.com/setup | bash -
#   or
# wget -qO- https://apt.filiosoft.com/setup | bash -
#

export DEBIAN_FRONTEND=noninteractive
FSPKG="mcpr-cli"

print_status() {
    echo
    echo "## $1"
    echo
}

if test -t 1; then # if terminal
    ncolors=$(which tput > /dev/null && tput colors) # supports color
    if test -n "$ncolors" && test $ncolors -ge 8; then
        termcols=$(tput cols)
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi

print_bold() {
    title="$1"
    text="$2"

    echo
    echo "${red}================================================================================${normal}"
    echo "${red}================================================================================${normal}"
    echo
    echo -e "  ${bold}${yellow}${title}${normal}"
    echo
    echo -en "  ${text}"
    echo
    echo "${red}================================================================================${normal}"
    echo "${red}================================================================================${normal}"
}

bail() {
    echo 'Error executing command, exiting'
    exit 1
}

exec_cmd_nobail() {
    echo "+ $1"
    bash -c "$1"
}

exec_cmd() {
    exec_cmd_nobail "$1" || bail
}

setup() {

print_status "Installing the Filiosoft repo..."

if $(uname -m | grep -Eq ^armv6); then
    print_status "You appear to be running on ARMv6 hardware. Unfortunately this is not currently supported by the Filiosoft Linux distributions."
    exit 1
fi

PRE_INSTALL_PKGS=""

# Check that HTTPS transport is available to APT
# (Check snaked from: https://get.docker.io/ubuntu/)

if [ ! -e /usr/lib/apt/methods/https ]; then
    PRE_INSTALL_PKGS="${PRE_INSTALL_PKGS} apt-transport-https"
fi

if [ ! -x /usr/bin/lsb_release ]; then
    PRE_INSTALL_PKGS="${PRE_INSTALL_PKGS} lsb-release"
fi

if [ ! -x /usr/bin/curl ] && [ ! -x /usr/bin/wget ]; then
    PRE_INSTALL_PKGS="${PRE_INSTALL_PKGS} curl"
fi

# Populating Cache
print_status "Populating apt-get cache..."
exec_cmd 'apt-get update'

if [ "X${PRE_INSTALL_PKGS}" != "X" ]; then
    print_status "Installing packages required for setup:${PRE_INSTALL_PKGS}..."
    # This next command needs to be redirected to /dev/null or the script will bork
    # in some environments
    exec_cmd "apt-get install -y${PRE_INSTALL_PKGS} > /dev/null 2>&1"
fi

IS_PRERELEASE=$(lsb_release -d | grep 'Ubuntu .*development' >& /dev/null; echo $?)
if [[ $IS_PRERELEASE -eq 0 ]]; then
    print_status "Your distribution, identified as \"$(lsb_release -d -s)\", is a pre-release version of Ubuntu. Filiosoft does not maintain official support for Ubuntu versions until they are formally released."
    exit 1
fi

DISTRO=$(lsb_release -c -s)

check_alt() {
    if [ "X${DISTRO}" == "X${2}" ]; then
        echo
        echo "## You seem to be using ${1} version ${DISTRO}."
        echo "## This maps to ${3} \"${4}\"... Adjusting for you..."
        DISTRO="${4}"
    fi
}

check_alt "Kali"          "sana"     "Debian" "jessie"
check_alt "Kali"          "kali-rolling" "Debian" "jessie"
check_alt "Linux Mint"    "maya"     "Ubuntu" "precise"
check_alt "Linux Mint"    "qiana"    "Ubuntu" "trusty"
check_alt "Linux Mint"    "rafaela"  "Ubuntu" "trusty"
check_alt "Linux Mint"    "rebecca"  "Ubuntu" "trusty"
check_alt "Linux Mint"    "rosa"     "Ubuntu" "trusty"
check_alt "Linux Mint"    "sarah"    "Ubuntu" "xenial"
check_alt "Linux Mint"    "serena"   "Ubuntu" "xenial"
check_alt "Linux Mint"    "sonya"    "Ubuntu" "xenial"
check_alt "LMDE"          "betsy"    "Debian" "jessie"
check_alt "elementaryOS"  "luna"     "Ubuntu" "precise"
check_alt "elementaryOS"  "freya"    "Ubuntu" "trusty"
check_alt "elementaryOS"  "loki"     "Ubuntu" "xenial"
check_alt "Trisquel"      "toutatis" "Ubuntu" "precise"
check_alt "Trisquel"      "belenos"  "Ubuntu" "trusty"
check_alt "BOSS"          "anokha"   "Debian" "wheezy"
check_alt "bunsenlabs"    "bunsen-hydrogen" "Debian" "jessie"
check_alt "Tanglu"        "chromodoris" "Debian" "jessie"

if [ "X${DISTRO}" == "Xdebian" ]; then
  print_status "Unknown Debian-based distribution, checking /etc/debian_version..."
  NEWDISTRO=$([ -e /etc/debian_version ] && cut -d/ -f1 < /etc/debian_version)
  if [ "X${NEWDISTRO}" == "X" ]; then
    print_status "Could not determine distribution from /etc/debian_version..."
  else
    DISTRO=$NEWDISTRO
    print_status "Found \"${DISTRO}\" in /etc/debian_version..."
  fi
fi

print_status 'Adding the Filiosoft signing key to your keyring...'

if [ -x /usr/bin/curl ]; then
    exec_cmd 'curl -s https://apt.filiosoft.com/archive.key | apt-key add -'
else
    exec_cmd 'wget -qO- https://apt.filiosoft.com/archive.key | apt-key add -'
fi

print_status "Creating apt sources list file for the Filiosoft repo..."

exec_cmd "echo 'deb https://apt.filiosoft.com/ stable main' > /etc/apt/sources.list.d/filiosoft.list"

print_status 'Running `apt-get update` for you...'

exec_cmd 'apt-get update'

print_status "Run \`apt-get install ${FSPKG}\` (as root) to install ${FSPKG}"

}

## Defer setup until we have the complete script
setup
