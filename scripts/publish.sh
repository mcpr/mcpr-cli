#!/bin/bash

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
gpg --import archive.key
gpg --list-secret-keys

if [ -z "$TRAVIS_TAG" ]
then
    DISTRIBUTION=nightly
    COMMENT="Nightly builds"
    LATEST_PREFIX=nightly
    echo "Nightly build"
else
    DISTRIBUTION=stable
    COMMENT="Stable builds"
    LATEST_PREFIX=stable
    echo "Stable build"
fi

aptly repo create -distribution=${DISTRIBUTION} -comment="${COMMENT}" -component=main mcpr-cli-release
aptly repo add mcpr-cli-release bin/${LATEST_PREFIX}/linux/${1}
aptly snapshot create mcpr-cli-${1} from repo mcpr-cli-release
aptly publish snapshot -batch=true -gpg-key="F56BD64C" -passphrase="$GPG_PWD" -architectures="i386,amd64,all" mcpr-cli-${1} s3:get.mcpr.io:
