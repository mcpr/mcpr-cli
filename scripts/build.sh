go get github.com/Masterminds/semver
go get github.com/briandowns/spinner
go get github.com/urfave/cli

if [ -z "$TRAVIS_TAG" ]
then
  echo ""
else
  echo "Release Version"
  echo $TRAVIS_TAG > version.txt
fi

VERSION=$(cat version.txt)

declare -a OS=(
  "windows"
  "darwin"
  "linux"
)

LAST_VER=$(cat version.txt)

if [ -z "$TRAVIS_TAG" ]
then
  echo "Not a tag."
  VERSION_NAME=${VERSION}-${TRAVIS_BUILD_NUMBER}
else
  echo "Building tag."
  VERSION_NAME=${TRAVIS_TAG}
  #sed -i -e "s/${LAST_VER}/${TRAVIS_TAG}/g" cli.go
  #echo ${TRAVIS_TAG} > version.txt
fi

echo "Building $VERSION_NAME"


for i in "${OS[@]}"
do
  if [ "$i" == "windows" ]; then
    FILENAME=mc-cli.exe
    OUT_FN=mc-${VERSION_NAME}-$i.exe
    LATEST_FN=mc.exe
  else
    FILENAME=mc-cli
    OUT_FN=mc-${VERSION_NAME}-$i
    LATEST_FN=mc
  fi
  echo 'Building '${i}''
  mkdir -p bin/${i}
  GOOS=${i} go build
  cp ${FILENAME} bin/${i}/${OUT_FN}
  mv ${FILENAME} bin/${i}/${LATEST_FN}
done

sed -i 's/^Version:.*$/Version: '"${VERSION_NAME}"'/g' control

cp bin/linux/mc .
equivs-build control
mv mc*.deb bin/linux

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

gpg --allow-secret-key-import --import private.key
gpg --list-secret-keys
echo ${GPG_KEY_PWD} > pwd.txt

aptly repo create -distribution=squeeze -component=main mc-cli-release
aptly repo add mc-cli-release bin/linux/
aptly snapshot create mc-cli-$VERSION_NAME from repo mc-cli-release
aptly publish snapshot -batch -gpg-key="C4B1ED8C" -passphrase-file="pwd.txt" -architectures="i386,amd64,all" mc-cli-${VERSION_NAME} s3:apt.filiosoft.com:
