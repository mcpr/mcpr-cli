FILENAME=deb/mc-cli_${VERSION_NUMBER}-${TRAVIS_BUILD_NUMBER}_all.deb

package_cloud push nprail/mc-cli/ubuntu/xenial $FILENAME
package_cloud push nprail/mc-cli/ubuntu/trusty $FILENAME
package_cloud push nprail/mc-cli/ubuntu/zesty $FILENAME
package_cloud push nprail/mc-cli/ubuntu/yakkety $FILENAME
package_cloud push nprail/mc-cli/ubuntu/wily $FILENAME