#!/bin/bash

echo -e "\n=============\nPublish Stage\n=============\n"

VERSION=$(cat version.txt)

if [ -z "$TRAVIS_TAG" ]
then
    echo "Not Tag"
    VERSION_NAME=${VERSION}-${TRAVIS_BUILD_NUMBER}
    LATEST_PREFIX="nightly"
else
    echo "Building Tag"
    VERSION_NAME=${TRAVIS_TAG}-${TRAVIS_BUILD_NUMBER}
    LATEST_PREFIX="stable"
fi

cat <<EOT > ~/.aptly.conf
{
   "S3PublishEndpoints":{
      "get.mcpr.io":{
         "region":"us-east-2",
         "bucket":"get.mcpr.io",
         "prefix":"debian",
         "acl":"public-read"
      }
   }
}
EOT

wget https://get.mcpr.io/debian/pubkey.gpg

if [ -z "$TRAVIS_TAG" ]
then
    DISTRIBUTION=nightly
    COMMENT="Nightly builds"
    echo -e "\nNightly build\n"
else
    DISTRIBUTION=stable
    COMMENT="Stable builds"
    echo -e "\nStable build\n"
fi

aptly repo create -distribution=${DISTRIBUTION} -comment="${COMMENT}" -component=main mcpr-cli-release
aptly repo add mcpr-cli-release bin/${LATEST_PREFIX}/linux/${VERSION_NAME}
aptly snapshot create mcpr-cli-${VERSION_NAME} from repo mcpr-cli-release
aptly publish snapshot -batch=true -gpg-key="F56BD64C" -passphrase="$GPG_PWD" -architectures="i386,amd64,all" mcpr-cli-${VERSION_NAME} s3:get.mcpr.io:
