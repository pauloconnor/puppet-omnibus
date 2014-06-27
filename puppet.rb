class PuppetGem < FPM::Cookery::Recipe
  description 'Puppet gem stack'

  # If you want to bump puppet version you have to do it in Gemfile as well
  name 'puppet'
  version '3.6.2'

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
    cleanenv_safesystem "echo 'install: -Nf' > ~/.gemrc"

    self.class.platforms [:ubuntu, :debian, :fedora, :redhat, :centos] do
      ENV['PKG_CONFIG_PATH'] = "#{destdir}/lib/pkgconfig"
      gem_install "#{workdir}/vendor/bundler-1.6.3.gem"
      cleanenv_safesystem "#{destdir}/bin/bundle config build.ruby-augeas --with-opt-dir=#{destdir}"
      cleanenv_safesystem "#{destdir}/bin/bundle install --local --gemfile #{workdir}/puppet/Gemfile"
    end

    self.class.platforms [:darwin] do
      cleanenv_safesystem "git clone -b osx git://github.com/apalmblad/ruby-shadow.git"
      cleanenv_safesystem "#{destdir}/bin/gem build #{workdir}/ruby-shadow/*.gemspec"
      cleanenv_safesystem "#{destdir}/bin/gem install --no-ri --no-rdoc #{workdir}/ruby-shadow/*.gem"
    end

    build_files
  end

  def install
    # Install init-script and puppet.conf
    install_files

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
    destdir('../var/lib/ruby').install workdir('puppet/seppuku_patch.rb')
    #destdir('../var/lib/ruby').install workdir('puppet/puppet_autoload_patch.rb')
    destdir('../var/lib/ruby').install workdir('puppet/gemspec_patch.rb')

    destdir('../var/lib/puppetmaster').mkdir
    destdir('../var/lib/puppetmaster/rack').mkdir
    destdir('../var/lib/puppetmaster/rack').install workdir('puppet/config.ru')

    destdir('../etc').mkdir
    destdir('../etc').install workdir('puppet/unicorn.conf')

    # Symlink binaries to PATH using update-alternatives
    with_trueprefix do
      create_post_install_hook
      create_pre_uninstall_hook
    end
  end

  private

  def gem_install(name, version = nil)
    v = version.nil? ? '' : "-v #{version}"
    cleanenv_safesystem "#{destdir}/bin/gem install --no-ri --no-rdoc #{v} #{name}"
  end

  platforms [:ubuntu, :debian] do
    def build_files
    end
    def install_files
    #  etc('puppet').mkdir
    #  etc('default').install builddir('puppet.default') => 'puppet'
    end
  end

  platforms [:fedora, :redhat, :centos] do
    def build_files
    end
    def install_files
    #  etc('puppet').mkdir
    end
  end

  def create_post_install_hook
    File.open(builddir('post-install'), 'w', 0755) do |f|
      f.write <<-__POSTINST
#!/bin/sh
set -e

if [ "$1" = "configure" ]; then

    # Create the "puppet" user
    if ! getent passwd puppet > /dev/null; then
        adduser --quiet --system --group --home /var/lib/puppet  \
            --no-create-home                                 \
            --gecos "Puppet configuration management daemon" \
            puppet
    fi

    # Set correct permissions and ownership for puppet directories
    if ! dpkg-statoverride --list /var/log/puppet >/dev/null 2>&1; then
        dpkg-statoverride --update --add puppet puppet 0750 /var/log/puppet
    fi

    if ! dpkg-statoverride --list /var/lib/puppet >/dev/null 2>&1; then
        dpkg-statoverride --update --add puppet puppet 0750 /var/lib/puppet
    fi

    # Create folders common to "puppet" and "puppetmaster", which need
    # to be owned by the "puppet" user
    install --owner puppet --group puppet --directory \
        /var/lib/puppet/state
fi

BIN_PATH="#{destdir}/bin"
BINS="puppet facter hiera"

for BIN in $BINS; do
  update-alternatives --install /usr/bin/$BIN $BIN $BIN_PATH/$BIN 100
done

exit 0
      __POSTINST
    end
  end

  def create_pre_uninstall_hook
    File.open(builddir('pre-uninstall'), 'w', 0755) do |f|
      f.write <<-__PRERM
#!/bin/sh

BIN_PATH="#{destdir}/bin"
BINS="puppet facter hiera"

if [ "$1" != "upgrade" ]; then
  for BIN in $BINS; do
    update-alternatives --remove $BIN $BIN_PATH/$BIN
  done
fi

exit 0
      __PRERM
    end
  end

end
