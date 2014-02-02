#!/bin/bash
if [ "$WORKSPACE" == "" ];then
  echo "WORKSPACE ENV variable not set, not in Jenkins - dieing"
  exit 2
fi
rm -rf $WORKSPACE/artifacts
pushd /
tar xzf $WORKSPACE/ruby-*.tgz
popd
export PATH="/opt/local/bin:/sbin:/usr/sbin:/opt/ruby/bin:$PATH"
/opt/ruby/bin/bundle install --binstubs
fakeroot /opt/ruby/bin/bundle exec bin/fpm-cook package recipe-aws.rb
mkdir $WORKSPACE/artifacts
mv $WORKSPACE/*.deb $WORKSPACE/*.rpm $WORKSPACE/artifacts/

