#!/bin/bash

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
    mkdir -p .go/src/github.com/mcpr/mcpr-cli
    cp -r * .go/src/github.com/mcpr/mcpr-cli
    mv .go go
    export GOPATH=$(pwd)/go
    gem install --no-ri --no-rdoc fpm
    go get github.com/sparrc/gdm
else
    openssl aes-256-cbc -K $encrypted_6e849d71586b_key -iv $encrypted_6e849d71586b_iv -in private.key.enc -out private.key -d
    sudo dpkg --add-architecture i386

    # setup aptly
    sudo sh -c 'echo "deb http://repo.aptly.info/ squeeze main" >> /etc/apt/sources.list'
    sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 9E3E53F19C7DE460
    sudo apt-get -qq update
    sudo apt-get install equivs aptly ruby ruby-dev build-essential rpm innoextract wine python-software-properties
    gem install --no-ri --no-rdoc fpm
    go get github.com/sparrc/gdm

    # inno setup
    wget -O is.exe http://files.jrsoftware.org/is/5/isetup-5.5.5.exe
    innoextract is.exe
    mkdir -p ~/".wine/drive_c/inno"
    cp -a app/* ~/".wine/drive_c/inno"
fi