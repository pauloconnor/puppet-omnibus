#!/bin/bash

cd /

if [ -z "$*" ]; then
  echo "$0 requires at least one argument (path to package to install)."
  exit 1
else
  packages_to_install=$*
  echo "Going to run integration tests on $packages_to_install"
fi

if [ -e /opt/puppet-omnibus ]; then
  echo "puppet-omnibus looks like is already here?"
  exit 1
fi

apt-get update
apt-get -y install gdebi-core
if gdebi -n $packages_to_install; then
  echo "Looks like it installed correctly"
else
  echo "Dpkg install failed"
  exit 1
fi

if [ -d /opt/puppet-omnibus ]; then
  echo "puppet-omnibus looks like it exists"
else
  echo "puppet-omnibus doesnt look like it is installed"
  exit 1
fi

if /opt/puppet-omnibus/bin/puppet --version; then
  echo "puppet-omnibus looks like it Works!"
else
  echo "puppet-omnibus --version failed"
  exit 1
fi

