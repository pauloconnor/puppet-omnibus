#!/bin/bash
if [ "$WORKSPACE" == "" ];then
  echo "WORKSPACE ENV variable not set, not in Jenkins - dieing"
  exit 2
fi
set -e
export PATH="/opt/local/bin:/sbin:/usr/sbin:/opt/ruby/bin:$PATH"

echo -n "Cleaning up workspace: "
rm -rf /opt/puppet /opt/ruby /opt/puppet-omnibus
rm -rf $WORKSPACE/artifacts
mkdir $WORKSPACE/artifacts
echo "Done"
echo -n "Unpacking bootstrap ruby: "
pushd /
tar xzf $WORKSPACE/ruby-*.tgz
popd
echo "Done"
echo "Going for bundle install and build:"
set -x
/opt/ruby/bin/bundle install --binstubs
fakeroot /opt/ruby/bin/bundle exec bin/fpm-cook package recipe-aws.rb
mv $WORKSPACE/*.deb $WORKSPACE/*.rpm $WORKSPACE/artifacts/

