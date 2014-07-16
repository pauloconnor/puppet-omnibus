#!/bin/bash
set -e
export PATH="/opt/puppet-omnibus/embedded/bin:/opt/local/bin:/sbin:/usr/sbin:$PATH"

set -x
if [ "$BUILD_NUMBER" == "" ];then
  echo "BUILD_NUMBER environment not set - producing debug build"
  export BUILD_NUMBER=debug0
fi
echo "Going for bundle install and build:"

export PUPPET_VERSION=3.6.2.y3
export PUPPET_DASHVER=${PUPPET_VERSION//./-}
export PUPPET_BUILDPATH=/tmp/puppet.$PUPPET_DASHVER

cp -r /package_source/* /package/

# build puppet gem
git clone -q git://github.com/Yelp/puppet.git $PUPPET_BUILDPATH # versioning here because of hardy
cd $PUPPET_BUILDPATH
git checkout -q $PUPPET_VERSION
rake package:bootstrap > /dev/null
rake package:gem > /dev/null
mv pkg/puppet-$PUPPET_VERSION.gem /package/vendor/

# build omnibus package
cd /package
echo 'install: -Nf' > ~/.gemrc
gem install /package/vendor/bundler-1.6.3.gem
bundle install --local --path /tmp
FPM_CACHE_DIR=/package/vendor bundle exec fpm-cook clean
FPM_CACHE_DIR=/package/vendor bundle exec fpm-cook package recipe.rb
echo "Copying package to the dist folder"
cp -v pkg/* /package_dest/
echo "Package copying worked!"
exit 0
