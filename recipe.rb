class PuppetOmnibus < FPM::Cookery::Recipe
  homepage 'https://github.com/bobtfish/puppet-omnibus'
  section 'Utilities'
  name 'puppet-omnibus'
  version '3.5.0'
  description 'Puppet Omnibus package'
  revision ENV['BUILD_NUMBER']

  vendor 'yelp-'

  maintainer '<tdoran@yelp.com>'
  license 'Apache 2.0 License'

  source '', :with => :noop

  omnibus_package true
  omnibus_dir     "/opt/#{name}"
  omnibus_recipes 'libaugeas',
                  'libyaml',
                  'ruby',
                  'puppet',
                  'aws',
                  'puppettools',
                  'nginx'
#  replaces 'puppet', 'puppet-common', 'hiera', 'yelp-hiera', 'facter', 'puppetmaster', 'puppetmaster-passenger', 'puppetmaster-common'
#  conflicts 'puppet', 'puppet-common', 'hiera', 'yelp-hiera', 'facter', 'puppetmaster', 'puppetmaster-passenger', 'puppetmaster-common'
#  provides 'puppet', 'puppet-common', 'hiera', 'yelp-hiera', 'facter', 'puppetmaster', 'puppetmaster-passenger', 'puppetmaster-common'

  # Set up paths to initscript and config files per platform
  platforms [:ubuntu, :debian] do
#    config_files '/etc/default/puppet'
  end
  platforms [:fedora, :redhat, :centos] do
#    config_files '/etc/sysconfig/puppet'
  end
#  omnibus_additional_paths config_files

  def build
    # Nothing
  end

  def install
    # Set paths to package scripts
    self.class.post_install builddir('post-install')
    self.class.pre_uninstall builddir('pre-uninstall')
  end
end
