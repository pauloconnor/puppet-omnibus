class PuppetToolsGem < FPM::Cookery::Recipe
  description 'Puppet tools and support gems'

  name 'puppettools'
  version '1.0.0'
  source "nothing", :with => :noop

  def build
    gem_install 'bundler'
    gem_install 'puppet-syntax', '1.1.0'               # MIT
    gem_install 'librarian-puppet', '0.9.10'           # Ruby
    gem_install 'rspec-core', '2.14.5'                 # MIT
    gem_install 'rspec-expectations', '2.14.2'         # MIT
    gem_install 'rspec-mocks', '2.14.3'                # MIT
    gem_install 'rspec', '2.14.1'                      # MIT
    gem_install 'rake-hooks', '1.2.3'                  # MIT
    gem_install 'rspec-puppet', '1.0.1'                # MIT
    gem_install 'puppetlabs_spec_helper', '0.4.1'      # Apache2
    gem_install 'sensu-plugin', '0.2.2'
    gem_install 'puppet-lint', '0.4.0.pre1'
    gem_install 'r10k', '1.2.0'
    gem_install 'pry'
    gem_install 'json'
    # gem 'rspec-hiera-puppet',                  # MIT
    #   :git => 'git://github.com/keymone/rspec-hiera-puppet.git',
    #   :ref => 'v0.3.1.1'
    # Due to https://github.com/rodjek/puppet-lint/issues/224
    # go back to forge as soon as there is a release
    # gem_install 'puppet-lint', '~> 0.4.0.pre1'         # MIT
    #    :git => 'git://github.com/rodjek/puppet-lint.git'
  end

  def install
  end

  private

  def gem_install(name, version = nil)
    v = version.nil? ? '' : "-v #{version}"
    cleanenv_safesystem "#{destdir}/bin/gem install --no-ri --no-rdoc #{v} #{name}"
  end
end
