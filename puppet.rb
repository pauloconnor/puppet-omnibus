# depends on ruby being installed in /opt/puppet-omnibus/embedded by ruby-build
class PuppetGem < FPM::Cookery::Recipe
  description 'Puppet gem stack'

  # If you want to bump puppet version you have to do it in Gemfile as well
  name 'puppet'
  version ENV['PUPPET_VERSION']

  source "nothing", :with => :noop

  platforms [:ubuntu, :debian] do
    ENV['BUNDLE_WITHOUT'] = 'centos_6'
    build_depends 'pkg-config', 'libxml2-dev', 'libxslt1-dev'
    depends 'libxml2', 'libxslt1.1'
  end

  platforms [:fedora, :redhat, :centos] do
    ENV['BUNDLE_WITHOUT'] = 'centos_6'
    build_depends 'pkgconfig', 'libxml2-devel', 'libxslt-devel'
    depends 'libxml2', 'libxslt'

    if IO.read('/etc/redhat-release') =~ /CentOS release 6/
      ENV['BUNDLE_WITHOUT'] = ''
      build_depends 'libvirt-devel'
      depends 'libvirt'
    end
  end

  def build
    self.class.platforms [:ubuntu, :debian, :fedora, :redhat, :centos] do
      ENV['PKG_CONFIG_PATH'] = "#{destdir}/lib/pkgconfig"
      cleanenv_safesystem "#{destdir}/bin/bundle config build.ruby-augeas \
                             --with-opt-dir=#{destdir}"

      cleanenv_safesystem "#{destdir}/bin/bundle config --delete path"
      cleanenv_safesystem "#{destdir}/bin/bundle install --local \
                             --gemfile #{workdir}/puppet/Gemfile"

      cleanenv_safesystem "#{destdir}/bin/gem clean"
      cleanenv_safesystem "#{destdir}/bin/gem install --no-ri --no-rdoc #{workdir}/vendor/puppet-#{ENV['PUPPET_VERSION']}.gem"

      # bundle is shit
      cleanenv_safesystem <<-SHELL
        for file in #{destdir}/bin/*; do
          if head -n1 $file | grep '^#!/usr/bin/env ruby'; then
            sed -i '1s/.*/#!#{destdir.to_s.gsub('/', "\\/")}\\/bin\\/ruby/' $file
          fi
        done
      SHELL
    end

    self.class.platforms [:darwin] do
      cleanenv_safesystem "git clone -b osx git://github.com/apalmblad/ruby-shadow.git"
      cleanenv_safesystem "#{destdir}/bin/gem build #{workdir}/ruby-shadow/*.gemspec"
      cleanenv_safesystem "#{destdir}/bin/gem install --no-ri --no-rdoc #{workdir}/ruby-shadow/*.gem"
    end
  end

  def install
    # Provide 'safe' binaries in /opt/<package>/bin like Vagrant does
    rm_rf "#{destdir}/../bin"
    destdir('../bin').mkdir
    destdir('../bin').install workdir('puppet/puppet'), 'puppet'
    destdir('../bin').install workdir('shared/omnibus.bin'), 'facter'
    destdir('../bin').install workdir('shared/omnibus.bin'), 'hiera'
    destdir('../bin').install workdir('puppet/unicorn'), 'unicorn'

    destdir('../var').mkdir
    destdir('../var/lib').mkdir

    destdir('../var/lib/ruby').mkdir
    destdir('../var/lib/ruby').install '/dev/null'
    destdir('../var/lib/ruby').install workdir('puppet/seppuku_patch.rb')

    destdir('../var/lib/puppetmaster').mkdir
    destdir('../var/lib/puppetmaster/rack').mkdir
    destdir('../var/lib/puppetmaster/rack').install workdir('puppet/config.ru')

    destdir('../etc').mkdir
    destdir('../etc').install workdir('puppet/unicorn.conf')
  end
end
