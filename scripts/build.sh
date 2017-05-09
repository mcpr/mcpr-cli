go get github.com/Masterminds/semver
go get github.com/briandowns/spinner
go get github.com/urfave/cli
mkdir -p packages/linux
mkdir -p packages/darwin
mkdir -p packages/windows

VERSION=$(cat version.txt)

echo "Building Linux"
go build
cp mc-cli packages/linux/mc-${VERSION}_${TRAVIS_BUILD_NUMBER}
mv mc-cli packages/linux/mc
echo "Building Darwin"
GOOS=darwin go build
cp mc-cli packages/darwin/mc-${VERSION}_${TRAVIS_BUILD_NUMBER}
mv mc-cli packages/darwin/mc
echo "Building Windows"
GOOS=windows go build
cp mc-cli.exe packages/windows/mc-${VERSION}_${TRAVIS_BUILD_NUMBER}.exe
mv mc-cli.exe packages/windows/mc.exe
