#!/bin/bash
set -e
export PATH="/opt/local/bin:/sbin:/usr/sbin:$PATH"

set -x
if [ "$BUILD_NUMBER" == "" ];then
  echo "BUILD_NUMBER environment not set - producing debug build"
  export BUILD_NUMBER=debug0
fi
echo "Going for bundle install and build:"
cd /package
cp -r /package_source/* /package/
echo 'install: -Nf' > ~/.gemrc
/opt/puppet-omnibus/embedded/bin/gem install /package/vendor/bundler-1.6.3.gem
/opt/puppet-omnibus/embedded/bin/bundle install --local \
  --binstubs /opt/puppet-omnibus/embedded/bin \
  --shebang /opt/puppet-omnibus/embedded/bin/ruby
FPM_CACHE_DIR=/package/vendor /opt/puppet-omnibus/embedded/bin/fpm-cook package recipe.rb
echo "Copying package to the dist folder"
cp -v pkg/* /package_dest/
echo "Package copying worked!"
exit 0
