go get github.com/Masterminds/semver
go get github.com/briandowns/spinner
go get github.com/urfave/cli
mkdir -p bin/linux
mkdir -p bin/darwin
mkdir -p bin/windows

if [ -v "$TRAVIS_TAG" ];
then
  echo "Release Version"
  echo $TRAVIS_TAG > version.txt
fi

VERSION=$(cat version.txt)

if [ -v "$TRAVIS_TAG" ];
then
  VERSION_NAME=v${TRAVIS_TAG}
else
  VERSION_NAME=v${VERSION}_${TRAVIS_BUILD_NUMBER}
fi

echo "Building $VERSION_NAME"

echo "Building Linux"
go build
cp mc-cli bin/linux/mc-${VERSION_NAME}
mv mc-cli bin/linux/mc

echo "Building Darwin"
GOOS=darwin go build
cp mc-cli bin/darwin/mc-${VERSION_NAME}
mv mc-cli bin/darwin/mc

echo "Building Windows"
GOOS=windows go build
cp mc-cli.exe bin/windows/mc-${VERSION_NAME}.exe
mv mc-cli.exe bin/windows/mc.exe

