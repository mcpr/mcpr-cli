#!/bin/bash

gdm restore

if [ -z "$TRAVIS_TAG" ]
then
  echo ""
else
  echo "Release Version"
  echo $TRAVIS_TAG > version.txt
fi

VERSION=$(cat version.txt)

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
  declare -a OS=(
    "darwin"
  )
else
  declare -a OS=(
    "windows"
    "linux"
  )
fi

LAST_VER=$(cat version.txt)

if [ -z "$TRAVIS_TAG" ]
then
  if [ -z "$TRAVIS_BUILD_NUMBER" ]
  then
    echo "Not Travis"
    VERSION_NAME=$VERSION
    LATEST_PREFIX="nightly"
  else
    echo "Not a tag"
    VERSION_NAME=${VERSION}-${TRAVIS_BUILD_NUMBER}
    LATEST_PREFIX="nightly"
  fi
else
  echo "Building tag."
  VERSION_NAME=${TRAVIS_TAG}-${TRAVIS_BUILD_NUMBER}
  LATEST_PREFIX="stable"
  #sed -i -e "s/${LAST_VER}/${TRAVIS_TAG}/g" main.go
  #echo ${TRAVIS_TAG} > version.txt
fi

echo "Building $VERSION_NAME"


for i in "${OS[@]}"
do
  if [ "$i" == "windows" ]; then
    FILENAME=mcpr-cli
    OUT_FN=mcpr-${VERSION_NAME}-$i.exe
    LATEST_FN=mcpr.exe
  else
    FILENAME=mcpr-cli
    OUT_FN=mcpr-${VERSION_NAME}-$i
    LATEST_FN=mcpr
  fi
  echo 'Building '${i}''
  mkdir -p bin/${i}/${VERSION_NAME}
  GOOS=${i} go build -o ${FILENAME}
  cp ${FILENAME} bin/${i}/${VERSION_NAME}/${OUT_FN}
  mv ${FILENAME} bin/${i}/${LATEST_FN}
done

cp bin/linux/mcpr mcpr
cp bin/windows/mcpr.exe mcpr.exe

# build deb
if [ -x "$(command -v equivs-build)" ];
then
  echo "Building DEB..."
  sed -i 's/^Version:.*$/Version: '"${VERSION_NAME}"'/g' control
  equivs-build --full control
  cp mcpr*.deb bin/linux/mcpr-cli_latest_all.deb
  mv mcpr*.deb bin/linux/${VERSION_NAME}
fi

# build rpm
if [ -x "$(command -v rpmbuild)" ] && [ -x "$(command -v fpm)" ];
then
  echo "Building RPM..."
  echo "%_gpg_name F56BD64C" > ~/.rpmmacros
  echo "$GPG_PWD" | fpm -s dir -t rpm -a all -v ${VERSION_NAME} -n mcpr-cli -d java-1.8.0-openjdk \
   --license MIT --vendor "Filiosoft, LLC" -m "Filiosoft Open Source <opensource@filiosoft.com>" \
   --url "https://cli.mcpr.io" --description "A CLI for setting up and controlling Minecraft servers." \
   --rpm-summary "The Official MCPR CLI!" ./bin/linux/mcpr=/usr/local/bin/mcpr
  cp mcpr*.rpm bin/linux/mcpr-cli-latest.noarch.rpm
  mv mcpr*.rpm bin/linux/${VERSION_NAME}
fi

# build pkg
if [ -x "$(command -v pkgbuild)" ];
then
  echo "Building PKG..."
  fpm -s dir -t osxpkg -v ${VERSION_NAME} -n mcpr-cli --osxpkg-identifier-prefix com.filiosoft ./bin/darwin/mcpr=/usr/local/bin/mcpr
  
  KEY_CHAIN=travis.keychain
  security default-keychain -s $KEY_CHAIN
  security unlock-keychain -p travis $KEY_CHAIN
  security find-certificate -a $KEY_CHAIN
  productsign --sign '3rd Party Mac Developer Installer: Filiosoft, LLC (U2PJ8B6P8N)' mcpr*.pkg mcpr-cli-signed.pkg
  cp mcpr-cli-signed.pkg bin/darwin/mcpr-cli-latest.pkg
  mv mcpr-cli-signed.pkg bin/darwin/${VERSION_NAME}/mcpr-cli-${VERSION_NAME}.pkg
fi

# build windows setup exe
if [ -x "$(command -v wine)" ];
then
  unset DISPLAY
  echo "Signing Windows Binary..."
  mv bin/windows/mcpr.exe bin/windows/mcpr-unsigned.exe
  osslsigncode sign -certs secure/authenticode.spc -key secure/authenticode.pvk -pass "$CODESIGN_PWD" \
  -n "MCPR-CLI" -i https://cli.mcpr.io/ \
	-t http://timestamp.verisign.com/scripts/timstamp.dll \
  -in bin/windows/mcpr-unsigned.exe -out bin/windows/mcpr.exe

  echo "Building Windows Installer..."
  wine "C:\inno\ISCC.exe" "scripts/setup.iss"

  echo 'Signing Windows Installer...'
  osslsigncode sign -certs secure/authenticode.spc -key secure/authenticode.pvk -pass "$CODESIGN_PWD" \
  -n "MCPR-CLI" -i https://cli.mcpr.io/ \
	-t http://timestamp.verisign.com/scripts/timstamp.dll \
  -in bin/mcpr-cli-setup.exe -out bin/mcpr-cli-setup-signed.exe

  cp bin/mcpr-cli-setup.exe bin/windows/${VERSION_NAME}/mcpr-cli-setup-${VERSION_NAME}.exe
  mv bin/mcpr-cli-setup.exe bin/windows/mcpr-cli-setup-latest.exe
  cp bin/mcpr-cli-setup-signed.exe bin/windows/${VERSION_NAME}/mcpr-cli-setup-signed-${VERSION_NAME}.exe
  mv bin/mcpr-cli-setup-signed.exe bin/windows/mcpr-cli-setup-signed-latest.exe
fi

if [ ! -z "$TRAVIS_TAG" ]
then
  mkdir -p github-release
  cp -r bin/linux/${VERSION_NAME}/* github-release || true
  cp -r bin/darwin/${VERSION_NAME}/* github-release || true
  cp -r bin/windows/${VERSION_NAME}/* github-release || true
  ls github-release
fi

# move to latest prefix (e.g. nightly) folder
mkdir $LATEST_PREFIX
mv bin/* $LATEST_PREFIX/
mv $LATEST_PREFIX bin/

if [ ! -z "$TRAVIS_BUILD_NUMBER" ] && [[ $TRAVIS_OS_NAME == 'linux' ]]
then

  bash scripts/publish.sh $VERSION_NAME
else
  echo "No publish"
fi