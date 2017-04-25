FILENAME=deb/mc-cli_${VERSION_NUMBER}-${TRAVIS_BUILD_NUMBER}_all.deb
BASE=hexagonminecraft/mc-cli

## OS versions to deploy to
declare -a VERSIONS=(
  "ubuntu/xenial"
  "ubuntu/trusty"
  "ubuntu/zesty"
  "ubuntu/yakkety"
  "ubuntu/wily"
  "ubuntu/precise"
  "debian/buster"
  "debian/stretch"
  "debian/jessie"
  "debian/wheezy"
  "raspbian/wheezy"
  "raspbian/jessie"
  "raspbian/stretch"
  "raspbian/buster"
)

## Do the deploys!
for i in "${VERSIONS[@]}"
do
   echo "Deploying $i to PackageCloud.io"
   package_cloud push $BASE/$i $FILENAME   
done