#!/bin/bash
if [ "$WORKSPACE" == "" ];then
  echo "WORKSPACE ENV variable not set, not in Jenkins - dieing"
  exit 2
fi
set -e
export PATH="/opt/local/bin:/sbin:/usr/sbin:/opt/ruby/bin:$PATH"

echo -n "Cleaning up workspace: "
rm -rf /opt/puppet /opt/ruby /opt/puppet-omnibus
rm -rf $WORKSPACE/pkg
echo "Done"
echo -n "Unpacking bootstrap ruby: "
pushd /
tar xzf $WORKSPACE/ruby-*.tgz
popd
echo "Done"
set -x
if [ "$BUILD_NUMBER" == "" ];then
  echo "BUILD_NUMBER environment not set - producing debug build"
  export BUILD_NUMBER=debug0
fi
echo "Going for bundle install and build:"
/opt/ruby/bin/bundle install --binstubs --local
fakeroot /opt/ruby/bin/bundle exec bin/fpm-cook package synapse-recipe.rb

