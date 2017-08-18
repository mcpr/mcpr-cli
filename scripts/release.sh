#!/bin/bash
VERSION=$1
CURRENT_VERSION=$(cat version.txt)
MESSAGE=$2


[[ -z $VERSION ]] && echo "Please specify a version. (e.g. scripts/release.sh <VERSION>)" && exit 1
[[ -z $CURRENT_VERSION ]] && echo "Current version not found. Please check your versions.txt file." && exit 1

git diff-index --quiet HEAD --
if [ $? -eq 0 ]; then
    echo OK
else
    echo "Please commit your changes before running."
    exit 1
fi
echo "Old Version: ${CURRENT_VERSION}"
exit 1
#set -e
echo -e "New Version: ${VERSION}\n"

echo "Setting version in control file..."
sed -i 's/^Version:.*$/Version: '"${VERSION}"'/g' control

echo "Setting version in cli.go..."
sed -i 's/'"${CURRENT_VERSION}"'/'"${VERSION}"'/g' cli.go

echo "Setting version in version.txt..."
echo $VERSION > version.txt

git add .
git commit -m "Version ${VERSION}"

echo "Creating git tag!"
if [[ -z $MESSAGE ]];
then 
    git tag ${VERSION}
else
    git tag ${VERSION} -m "${MESSAGE}"
fi
