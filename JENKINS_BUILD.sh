#!/bin/bash
set -e
export PATH="/opt/local/bin:/sbin:/usr/sbin:/opt/ruby/bin:$PATH"

set -x
if [ "$BUILD_NUMBER" == "" ];then
  echo "BUILD_NUMBER environment not set - producing debug build"
  export BUILD_NUMBER=debug0
fi
echo "Going for bundle install and build:"
cd /package
cp -r /package_source/* /package/
/opt/ruby/bin/bundle install --binstubs --local
fakeroot /opt/ruby/bin/bundle exec bin/fpm-cook package recipe.rb
echo "Copying package to the dist folder"
env
set -vx
echo About to put files in /package_dest/
ls -lha /package_dest/
cp -v pkg/* /package_dest/
exit 0
