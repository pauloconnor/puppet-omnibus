# NOTE: This file is maintained in the puppet-omnibus package, NOT by puppet
#
# a config.ru, for use with every rack-compatible webserver.
# SSL needs to be handled outside this, though.

# if puppet is not in your RUBYLIB:
# $:.unshift('/opt/puppet/lib')

Encoding.default_external = Encoding::UTF_8

$0 = "master"

# if you want debugging:
# ARGV << "--debug"

ARGV << "--rack"
ARGV << "--confdir" << "/etc/puppetmaster"
ARGV << "--vardir" << "/var/lib/puppetmaster"

require 'puppet/util/command_line'

run Puppet::Util::CommandLine.new.execute

