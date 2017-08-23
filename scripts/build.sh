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
  mkdir -p bin/${i}/${VERSION_NAME}
  GOOS=${i} go build -o ${FILENAME}
  cp ${FILENAME} bin/${i}/${VERSION_NAME}/${OUT_FN}
  mv ${FILENAME} bin/${i}/${VERSION_NAME}/${LATEST_FN}
done

sed -i 's/^Version:.*$/Version: '"${VERSION_NAME}"'/g' control

cp bin/linux/${VERSION_NAME}/mcpr .
mv mcpr bin/linux/mcpr

# build deb
equivs-build control
# build rpm
fpm -s dir -t rpm -v ${VERSION_NAME} -n mcpr-cli ./mcpr=/usr/bin

# copy deb and rpm to latest
cp mcpr*.deb bin/linux/mcpr-cli_latest_all.deb
cp mcpr*.rpm bin/linux/mcpr-cli-latest.x86_64.rpm

# move deb and rpm to version folder
mv mcpr*.deb bin/linux/${VERSION_NAME}
mv mcpr*.rpm bin/linux/${VERSION_NAME}

bash scripts/publish.sh $VERSION_NAME
