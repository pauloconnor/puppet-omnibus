Omnibus Puppet package project
==============================

This is an Omnibus project that will build a "monolithic" OS package for Puppet.
It installs a source-built Ruby in /opt/puppet-omnibus, then installs all the
gems required for Puppet to work into this Ruby. This means it leaves the
system-supplied Ruby completely untouched, along with any other Rubies you might
happen to have installed.

Why create a monolithic Puppet package?
---------------------------------------

The goal was to create a Puppet package that could be dropped onto a system at
the end of the OS install and immediately begin to manage the system in its
entirety, which includes installing and managing the Ruby versions on the
machine. Keeping Puppet separate from Rubies used to run applications means this
is possible (and it also means you can't break your config management agent by
mucking around with Ruby).

What are Omnibus packages?
--------------------------

[Omnibus](https://github.com/opscode/omnibus-ruby) is an OS packaging system
built in Ruby, written by the Opscode folks. It was created to build monolithic
packages for Chef (which requires Ruby as well). Rather than re-inventing the
packaging wheel, it makes use of Jordan Sissel's
[fpm](https://github.com/jordansissel/fpm) to build the final package.

The first version of this project used Opscode's tool, but they didn't seem to
take pull requests, so I enhanced bernd's superb
[fpm-cookery](https://github.com/bernd/fpm-cookery) to create Omnibus packages,
and switched this project to use it.

Runtime OS package dependencies
-------------------------------

Obviously some components of Ruby/Puppet/Facter have library dependencies.
Opscode take the approach of building *any* binary component from source and
having it inside the package. I think this is wasteful if you only have a few OS
dependencies - instead, the final package this project builds depends on the OS
packages, so apt/yum will automatically pull them in when you install the
package.

The exception is libyaml, which now gets built into the Omnibus; this is to help
support RHEL/Centos etc without needing EPEL.

Available builds
----------------

There are two recipes available - `recipe-aws.rb`, which includes some gems to
support Puppet types that make use of AWS resources, and `recipe.rb`, for people
not using AWS.

The following gems are built into both recipes:
- facter
- json\_pure
- hiera
- deep\_merge
- rgen
- ruby-augeas
- ruby-shadow
- gpgme
- puppet
- unicorn

The following extra gems are included in the `recipe-aws.rb` build:
- aws-sdk
- fog

Package contents
----------------

Besides Ruby and associated gems, the package also places scripts to run the
puppet, facter and hiera binaries in /usr/bin using update-alternatives. It
deploys an appropriate init script based on the official Puppetlabs script,
config files, and files in `/etc/default` / `/etc/sysconfig`.

How do I build the package?
---------------------------

You need to clone the repository and bundle it:

    $ git clone https://github.com/bobtfish/puppet-omnibus

Build process is relying heavily on Docker now since we need to build package
for many different distribs. To build Ubuntu Lucid package use:

    $ rake package_lucid

this will prepare(and store with a checksum) a Docker image for Lucid and
run build process. Resulting package will be under dist/lucid.

Build process reference
-----------------------

There are many tools in use here, here's a quick list:

- make (Makefile) - used by jenkins, provides itest\_$package entrypoints
- rake (Rakefile) - used to compile docker images and initiate package building
- rocker.rb (Rockerfile) - used to generate Dockerfiles for different distribs
- fpm (recipe.rb, puppet.rb, etc) - actual building and generating debs/rpms

How things look from Jenkins point of view
------------------------------------------

- make itest\_lucid
  - rake itest\_lucid
    - invoke package\_lucid
      - generate Dockerfile
      - invoke docker\_lucid if image for Dockerfile checksum doesnt exist
        - build docker image
        - install ruby 2.1.2 inside docker image
        - if all is good - tag image with Dockerfile checksum
      - run JENKINS_BUILD.sh inside prepared docker image
        - build puppet gem from github.com/Yelp/puppet.git fork
        - bundle gems needed for fpm and run fpm
        - move built package to dest folder
    - run itest script against new package in docker

Configuration
-------------

Unicorn server can be configured via following env variables:

- PUPPET_OMNIBUS_LOG (/var/log/puppetmaster) where do unicorn logs go
- PUPPET_OMNIBUS_WORKERS (12) number of workers
- PUPPET_OMNIBUS_WMLIMIT (500 000) memory limit for worker process in Kilobytes
- PUPPET_OMNIBUS_WRLIMIT (1000) maximum number of requests worker can process

Testing
-------

I use this in production with Ubuntu 12.04. [beddari](https://github.com/beddari)
reports it working on Fedora, CentOS and RHEL.

Credits
-------

Credit for the Omnibus idea goes to the [Opscode](www.opscode.com) and
[Sensu](http://sensuapp.org/) folks. Credit for coming up with the idea of
packaging Puppet like Chef belongs to my colleague
[lloydpick](https://github.com/lloydpick). Thanks to
[bernd](https://github.com/bernd) for the
awesome [fpm-cookery](https://github.com/bernd/fpm-cookery) and for taking my
PRs. Thanks to [beddari](https://github.com/beddari) for his PRs to support RHEL
derivatives, and his almost complete overhaul of the project.
