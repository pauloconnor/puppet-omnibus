# TODO: fix this upstream
class FPM::Cookery::Path
  def encoding
    @encoding ||= Encoding.find("filesystem")
  end
end

class PuppetOmnibus < FPM::Cookery::Recipe
  homepage 'https://github.com/bobtfish/puppet-omnibus'
  section 'Utilities'
  name 'puppet-omnibus'
  version '3.6.2'
  description 'Puppet Omnibus package'
  revision ENV['BUILD_NUMBER']

  vendor 'yelp-'

  maintainer '<tdoran@yelp.com>'
  license 'Apache 2.0 License'

  source '', :with => :noop

  omnibus_package true
  omnibus_dir     "/opt/#{name}"
  omnibus_recipes 'libaugeas', 'puppet', 'nginx'

  #  replaces 'puppet', 'puppet-common', 'hiera', 'yelp-hiera', 'facter', 'puppetmaster', 'puppetmaster-passenger', 'puppetmaster-common'
  #  conflicts 'puppet', 'puppet-common', 'hiera', 'yelp-hiera', 'facter', 'puppetmaster', 'puppetmaster-passenger', 'puppetmaster-common'
  #  provides 'puppet', 'puppet-common', 'hiera', 'yelp-hiera', 'facter', 'puppetmaster', 'puppetmaster-passenger', 'puppetmaster-common'
  # omnibus_additional_paths config_files

  def build
  end

  def install
    # Set paths to package scripts
    self.class.post_install builddir('post-install')
    self.class.pre_uninstall builddir('pre-uninstall')
  end
end
