#!/bin/bash
VERSION=$1
CURRENT_VERSION=$(cat version.txt)
MESSAGE=$2


[[ -z $VERSION ]] && echo "Please specify a version. (e.g. scripts/release.sh <VERSION>)" && exit 1
[[ -z $CURRENT_VERSION ]] && echo "Current version not found. Please check your versions.txt file." && exit 1

if [ -z "$(git status --porcelain)" ]; then 
  echo "Working directory clean"
else 
  echo "Uncommitted changes"
fi

set -e

echo "Old Version: ${CURRENT_VERSION}"

echo -e "New Version: ${VERSION}\n"

echo "Setting version in control file..."
sed -i 's/^Version:.*$/Version: '"${VERSION}"'/g' control

echo "Setting version in cli.go..."
sed -i 's/'"${CURRENT_VERSION}"'/'"${VERSION}"'/g' cli.go

echo "Setting version in version.txt..."
echo $VERSION > version.txt

git add .
git commit -s -m "Version ${VERSION}"

echo "Creating git tag!"
if [[ -z $MESSAGE ]];
then 
    git tag -s ${VERSION}
else
    git tag -s ${VERSION} -m "${MESSAGE}"
fi
