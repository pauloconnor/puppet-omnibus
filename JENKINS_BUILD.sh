#!/bin/bash
set -e
export PATH="/opt/puppet-omnibus/embedded/bin:/opt/local/bin:/sbin:/usr/sbin:$PATH"

set -x
if [ "$BUILD_NUMBER" == "" ];then
  echo "BUILD_NUMBER environment not set - producing debug build"
  export BUILD_NUMBER=debug0
fi
echo "Going for bundle install and build:"

cp -r /package_source/* /package/

# build puppet gem
cd /tmp
git clone git://github.com/Yelp/puppet.git
cd puppet
git checkout 7c93c861d9cb70492641b3f093d2e13b3fdc094b
rake package:bootstrap
rake package:gem
mv pkg/puppet-3.6.2.y2.gem /package/vendor/

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
