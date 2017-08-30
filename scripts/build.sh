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
    LATEST_FN=mcpr-${LATEST_PREFIX}.exe
  else
    FILENAME=mcpr-cli
    OUT_FN=mcpr-${VERSION_NAME}-$i
    LATEST_FN=mcpr-${LATEST_PREFIX}
  fi
  echo 'Building '${i}''
  mkdir -p bin/${i}/${VERSION_NAME}
  GOOS=${i} go build -o ${FILENAME}
  cp ${FILENAME} bin/${i}/${VERSION_NAME}/${OUT_FN}
  mv ${FILENAME} bin/${i}/${LATEST_FN}
done

cp bin/linux/mcpr-${LATEST_PREFIX} mcpr
cp bin/windows/mcpr-${LATEST_PREFIX}.exe mcpr.exe

# build deb
if [ -x "$(command -v equivs-build)" ];
then
  echo "Building DEB..."
  sed -i 's/^Version:.*$/Version: '"${VERSION_NAME}"'/g' control
  equivs-build control
  cp mcpr*.deb bin/linux/mcpr-cli_${LATEST_PREFIX}_latest_all.deb
  mv mcpr*.deb bin/linux/${VERSION_NAME}
fi

# build rpm
if [ -x "$(command -v rpmbuild)" ] && [ -x "$(command -v fpm)" ];
then
  echo "Building RPM..."
  fpm -s dir -t rpm -a all -v ${VERSION_NAME} -n mcpr-cli -d java-1.8.0-openjdk \
   --license MIT --vendor "Filiosoft, LLC" -m "Filiosoft Open Source <opensource@filiosoft.com>" \
   --url "https://mcpr.github.io/mcpr-cli" --description "A CLI for setting up and controlling Minecraft servers." \
   --rpm-summary "The Official MCPR CLI!" ./bin/linux/mcpr-${LATEST_PREFIX}=/usr/local/bin/mcpr
  cp mcpr*.rpm bin/linux/mcpr-cli-${LATEST_PREFIX}-latest.noarch.rpm
  mv mcpr*.rpm bin/linux/${VERSION_NAME}
fi

# build pkg
if [ -x "$(command -v pkgbuild)" ];
then
  echo "Building PKG..."
  fpm -s dir -t osxpkg -v ${VERSION_NAME} -n mcpr-cli --osxpkg-identifier-prefix com.filiosoft ./bin/darwin/mcpr-${LATEST_PREFIX}=/usr/local/bin/mcpr
  cp mcpr*.pkg bin/darwin/mcpr-cli-${LATEST_PREFIX}-latest.pkg
  mv mcpr*.pkg bin/darwin/${VERSION_NAME}
fi

# build windows setup exe
if [ -x "$(command -v wine)" ];
then
  echo "Building Windows Setup..."
  unset DISPLAY
  wine "C:\inno\ISCC.exe" "scripts/setup.iss"
  cp bin/mcpr-cli-setup.exe bin/windows/${VERSION_NAME}/mcpr-cli-setup-${VERSION_NAME}.exe
  mv bin/mcpr-cli-setup.exe bin/windows/mcpr-cli-setup-${LATEST_PREFIX}-latest.exe
fi

if [ ! -z "$TRAVIS_TAG" ]
then
  mkdir -p github-release
  cp -r bin/linux/${VERSION_NAME}/* github-release || true
  cp -r bin/darwin/${VERSION_NAME}/* github-release || true
  cp -r bin/windows/${VERSION_NAME}/* github-release || true
  ls github-release
fi

if [ ! -z "$TRAVIS_BUILD_NUMBER" ] && [[ $TRAVIS_OS_NAME == 'linux' ]]
then

  bash scripts/publish.sh $VERSION_NAME
else
  echo "No publish"
fi