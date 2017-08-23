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
  echo "Not a tag."
  VERSION_NAME=${VERSION}-${TRAVIS_BUILD_NUMBER}
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
  mkdir -p bin/${i}
  GOOS=${i} go build -o ${FILENAME}
  cp ${FILENAME} bin/${i}/${OUT_FN}
  mv ${FILENAME} bin/${i}/${LATEST_FN}
done

sed -i 's/^Version:.*$/Version: '"${VERSION_NAME}"'/g' control

cp bin/linux/mcpr .
equivs-build control
fpm -s dir -t rpm -v ${VERSION_NAME} -n mcpr-cli ./bin/linux=/usr/bin
mv mcpr*.deb bin/linux
mv mcpr*.rpm bin/linux

bash scripts/publish.sh $VERSION_NAME
