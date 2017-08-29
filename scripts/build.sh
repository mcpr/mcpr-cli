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

declare -a OS=(
  "windows"
  "darwin"
  "linux"
)

LAST_VER=$(cat version.txt)

if [ -z "$TRAVIS_TAG" ]
then
  if [ -z "$TRAVIS_BUILD_NUMBER" ]
  then
    echo "Not Travis"
    VERSION_NAME=$VERSION
  else
    echo "Not a tag."
    VERSION_NAME=${VERSION}-${TRAVIS_BUILD_NUMBER}
  fi
else
  echo "Building tag."
  VERSION_NAME=${TRAVIS_TAG}-${TRAVIS_BUILD_NUMBER}
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

cp bin/linux/mcpr .

# build deb
if [ -x "$(command -v equivs-build)" ];
then
  echo "Building DEB..."
  sed -i 's/^Version:.*$/Version: '"${VERSION_NAME}"'/g' control
  equivs-build control
  cp mcpr*.deb bin/linux/mcpr-cli_latest_all.deb
  mv mcpr*.deb bin/linux/${VERSION_NAME}
fi

# build rpm
if [ -x "$(command -v rpmbuild)" ] && [ -x "$(command -v fpm)" ];
then
  echo "Building RPM..."
  fpm -s dir -t rpm -v ${VERSION_NAME} -n mcpr-cli -d java-1.8.0-openjdk ./bin/linux/mcpr=/usr/local/bin/mcpr
  cp mcpr*.rpm bin/linux/mcpr-cli-latest.x86_64.rpm
  mv mcpr*.rpm bin/linux/${VERSION_NAME}
fi

# build pkg
if [ -x "$(command -v pkgbuild)" ];
then
  echo "Building PKG..."
  fpm -s dir -t osxpkg -v ${VERSION_NAME} -n mcpr-cli ./bin/darwin/mcpr=/usr/local/bin/mcpr
  cp mcpr*.pkg bin/darwin/mcpr-cli-latest.pkg
  mv mcpr*.pkg bin/darwin/${VERSION_NAME}
fi

# build windows setup exe
if [ -x "$(command -v wine)" ];
then
  echo "Building Windows Setup..."
  unset DISPLAY
  wine "C:\inno\ISCC.exe" "scripts/setup.iss"
  cp bin/mcpr-windows-setup.exe bin/windows/${VERSION_NAME}/mcpr-${VERSION_NAME}-windows-setup.exe
  mv bin/mcpr-windows-setup.exe bin/windows/mcpr-windows-setup.exe
fi

if [ ! -z "$TRAVIS_BUILD_NUMBER" ] && [[ $TRAVIS_OS_NAME == 'linux' ]]
then
  bash scripts/publish.sh $VERSION_NAME
else
  echo "No publish"
fi