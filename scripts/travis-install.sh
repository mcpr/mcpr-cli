#!/bin/bash

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
    # decrypt everything
    echo -e "\n==========\nDecrypting\n==========\n"
    openssl aes-256-cbc -K $encrypted_ab1f4736f273_key -iv $encrypted_ab1f4736f273_iv -in secrets.tar.enc -out secrets.tar -d
    tar xvf secrets.tar

    echo -e "\n===========\nPrepping Go\n===========\n"
    mkdir -p .go/src/github.com/mcpr/mcpr-cli
    cp -r * .go/src/github.com/mcpr/mcpr-cli
    mv .go go
    export GOPATH=$(pwd)/go
    export PATH=$PATH:$GOPATH/bin
    cd go/src/github.com/mcpr/mcpr-cli

    echo -e "\n=======================\nInstalling Dependencies\n=======================\n"
    go get github.com/sparrc/gdm
    gem install --no-ri --no-rdoc fpm

    # setup keychain and import the key
    echo -e "\n=================\nPrepping Keychain\n=================\n"
    KEY_CHAIN=travis.keychain

    echo "Create Keychain"
    security create-keychain -p travis $KEY_CHAIN
    security default-keychain -s $KEY_CHAIN
    security unlock-keychain -p travis $KEY_CHAIN
    security set-keychain-settings -t 3600 -u $KEY_CHAIN

    echo "Import Certificates"
    security add-certificates -k $KEY_CHAIN secure/mac_installer.cer
    security import secure/macos-private.p12 -k $KEY_CHAIN -P $PRIVATE_KEY_PWD -A
else
    # decrypt everything
    echo -e "\n==========\nDecrypting\n==========\n"
    openssl aes-256-cbc -K $encrypted_ab1f4736f273_key -iv $encrypted_ab1f4736f273_iv -in secrets.tar.enc -out secrets.tar -d
    tar xvf secrets.tar

    # import gpg keys
    gpg --allow-secret-key-import --import secure/filiosoft-signing-key.asc

    # setup aptly & install deps
    echo -e "\n=======================\nInstalling Dependencies\n=======================\n"
    sudo dpkg --add-architecture i386
    sudo sh -c 'echo "deb http://repo.aptly.info/ squeeze main" >> /etc/apt/sources.list'
    sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 9E3E53F19C7DE460
    sudo add-apt-repository -y ppa:likemartinma/osslsigncode
    sudo apt-get -qq update
    sudo apt-get install equivs aptly ruby ruby-dev build-essential rpm innoextract wine python-software-properties osslsigncode debsigs
    gem install --no-ri --no-rdoc fpm

    pyenv global system 3.5
    pip3 install mkdocs mkdocs-material

    go get github.com/sparrc/gdm

    # inno setup
    echo -e "\n=====================\nInstalling Inno Setup\n=====================\n"
    wget -O is.exe http://files.jrsoftware.org/is/5/isetup-5.5.5.exe
    innoextract is.exe
    mkdir -p ~/".wine/drive_c/inno"
    cp -a app/* ~/".wine/drive_c/inno"
fi

echo "\nInstall Complete!\n"