#!/bin/bash

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
    mkdir -p .go/src/github.com/mcpr/mcpr-cli
    cp -r * .go/src/github.com/mcpr/mcpr-cli
    mv .go go
    export GOPATH=$(pwd)/go
    gem install --no-ri --no-rdoc fpm
    go get github.com/sparrc/gdm

    # decrypt everything
    openssl aes-256-cbc -K $encrypted_ab1f4736f273_key -iv $encrypted_ab1f4736f273_iv -in secrets.tar.enc -out secrets.tar -d
    tar xvf secrets.tar

    # setup keychain and import the key
    KEY_CHAIN=travis.keychain
    security create-keychain -p travis $KEY_CHAIN
    security default-keychain -s $KEY_CHAIN
    security unlock-keychain -p travis $KEY_CHAIN
    security set-keychain-settings -t 3600 -u $KEY_CHAIN
    security import mac_installer.cer -k $KEY_CHAIN -P travis -T /usr/bin/productsign
    security find-certificate -a KEY_CHAIN
else
    # decrypt everything
    openssl aes-256-cbc -K $encrypted_ab1f4736f273_key -iv $encrypted_ab1f4736f273_iv -in secrets.tar.enc -out secrets.tar -d
    tar xvf secrets.tar

    # import gpg keys
    gpg --allow-secret-key-import --import filiosoft-apt-signing-private.key
    gpg --allow-secret-key-import --import filiosoft-signing-private.key

    # setup aptly & install deps
    sudo dpkg --add-architecture i386
    sudo sh -c 'echo "deb http://repo.aptly.info/ squeeze main" >> /etc/apt/sources.list'
    sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 9E3E53F19C7DE460
    sudo add-apt-repository -y ppa:likemartinma/osslsigncode
    sudo apt-get -qq update
    sudo apt-get install equivs aptly ruby ruby-dev build-essential rpm innoextract wine python-software-properties osslsigncode debsigs
    gem install --no-ri --no-rdoc fpm
    go get github.com/sparrc/gdm

    # inno setup
    wget -O is.exe http://files.jrsoftware.org/is/5/isetup-5.5.5.exe
    innoextract is.exe
    mkdir -p ~/".wine/drive_c/inno"
    cp -a app/* ~/".wine/drive_c/inno"
fi