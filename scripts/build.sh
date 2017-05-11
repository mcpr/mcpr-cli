go get

if [ -v "$TRAVIS_TAG" ];
then
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

if [ -v "$TRAVIS_TAG" ];
then
  VERSION_NAME=v${TRAVIS_TAG}
  sed -i -e "s/${LAST_VER}/${TRAVIS_TAG}/g" cli.go
  echo ${TRAVIS_TAG} > version.txt
else
  VERSION_NAME=v${VERSION}_${TRAVIS_BUILD_NUMBER}
fi

echo "Building $VERSION_NAME"


for i in "${OS[@]}"
do
  if [ "$i" == "windows" ]; then
    FILENAME=mc-cli.exe
    OUT_FN=mc-${VERSION_NAME}.exe
    LATEST_FN=mc.exe
  else
    FILENAME=mc-cli
    OUT_FN=mc-${VERSION_NAME}
    LATEST_FN=mc
  fi
  echo 'Building '${i}''
  mkdir -p bin/${i}
  GOOS=${i} go build
  cp ${FILENAME} bin/${i}/${OUT_FN}
  mv ${FILENAME} bin/${i}/${LATEST_FN}
done
