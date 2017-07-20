#!/bin/bash

cat <<EOT > ~/.aptly.conf
{
   "S3PublishEndpoints":{
      "apt.filiosoft.com":{
         "region":"us-east-1",
         "bucket":"apt.filiosoft.com",
         "acl":"public-read"
      }
   }
}
EOT

wget -qO - https://apt.filiosoft.com/archive.key
gpg --allow-secret-key-import --import private.key
gpg --import archive.key
gpg --list-secret-keys

aptly repo create -distribution=squeeze -component=main mc-cli-release
aptly repo add mc-cli-release bin/linux/
aptly snapshot create mc-cli-$1 from repo mc-cli-release
aptly publish snapshot -batch=true -gpg-key="F2EF7271" -architectures="i386,amd64,all" mc-cli-${1} s3:apt.filiosoft.com:
