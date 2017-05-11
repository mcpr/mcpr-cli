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
  VERSION_NAME=v${VERSION}_${TRAVIS_BUILD_NUMBER}
else
  echo "Building tag."
  VERSION_NAME=v${TRAVIS_TAG}
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
