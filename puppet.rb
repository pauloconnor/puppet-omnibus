class PuppetGem < FPM::Cookery::Recipe
  description 'Puppet gem stack'

  name 'puppet'
  version '3.0.2'

  source "nothing", :with => :noop

  platforms [:ubuntu, :debian] do
    build_depends 'pkg-config'
  end

  platforms [:fedora, :redhat, :centos] do
    build_depends 'pkgconfig'
    redhat = IO.read('/etc/redhat-release')
    releaseno = /CentOS release (\d)/.match(redhat)[1]
    if releaseno == '6'
      build_depends 'libvirt-devel'
      depends 'libvirt'
    end

  end

  def build
    # Install gems using the gem command from destdir
    gem_install 'nokogiri',    '1.4.3' # N.b. ruby-libvirt pins this here
    gem_install 'facter',      '1.7.3'
    gem_install 'json_pure',   '1.8.0'
    gem_install 'hiera',       '1.3.0'
    gem_install 'deep_merge',  '1.0.0'
    gem_install 'rgen',        '0.6.5'
    ENV['PKG_CONFIG_PATH'] = '/opt/puppet-omnibus/embedded/lib/pkgconfig'
    gem_install 'ruby-augeas -- --with-opt-dir=/opt/puppet-omnibus/embedded', '0.4.1'
    self.class.platforms [:ubuntu, :debian, :fedora, :redhat, :centos] do
      gem_install 'ruby-shadow', '2.2.0'
    end
    self.class.platforms [:darwin] do
      cleanenv_safesystem "git clone -b osx git://github.com/apalmblad/ruby-shadow.git"
      cleanenv_safesystem "#{destdir}/bin/gem build #{workdir}/ruby-shadow/*.gemspec"
      cleanenv_safesystem "#{destdir}/bin/gem install --no-ri --no-rdoc #{workdir}/ruby-shadow/*.gem"
    end
    self.class.platforms [:fedora, :redhat, :centos] do
      redhat = IO.read('/etc/redhat-release')
      releaseno = /CentOS release (\d)/.match(redhat)[1]
      if releaseno == '6'
        gem_install 'ruby-libvirt','0.4.0'
      end
    end 
    gem_install 'gpgme',       '2.0.2'
    gem_install 'highline',    '1.6.20' # Ruby
    gem_install 'trollop',     '2.0' # ??? FIXME
    gem_install 'hiera-eyaml', '2.0.0' # MIT
    gem_install 'rack',        '1.5.2'
    gem_install 'unicorn',     '4.8.1'
    gem_install name,          version
    # Download init scripts and conf
    build_files

    # Nasty hack to make puppet be able to use facter 1.7.3
    cleanenv_safesystem "rm -r #{destdir}/lib/ruby/gems/1.9.1/gems/facter-1.6.18 #{destdir}/lib/ruby/gems/1.9.1/cache/facter-1.6.18.gem"
    cleanenv_safesystem "sed -i -e's/1.6.11/1.7.3/' #{destdir}/lib/ruby/gems/1.9.1/specifications/puppet-3.0.2.gemspec"
    File.open("#{destdir}/user.patch", 'w', 0755) do |f|
      f.write <<-__USERPATCH
--- lib/ruby/gems/1.9.1/gems/puppet-3.0.2/lib/puppet/type/user_old.rb   2014-03-28 16:28:17.956743521 +0000
+++ lib/ruby/gems/1.9.1/gems/puppet-3.0.2/lib/puppet/type/user.rb   2014-03-28 16:27:41.485265388 +0000
@@ -158,6 +158,9 @@

     newproperty(:comment) do
       desc "A description of the user.  Generally the user's full name."
+      munge do |v|
+        v.respond_to?(:force_encoding) ? v.force_encoding(Encoding::ASCII_8BIT) : v
+      end
     end

     newproperty(:shell) do
__USERPATCH
    end
    cleanenv_safesystem "cd #{destdir} ; patch -p0 < user.patch && rm user.patch"
  end

  def install
    # Install init-script and puppet.conf
    install_files

    # Provide 'safe' binaries in /opt/<package>/bin like Vagrant does
    rm_rf "#{destdir}/../bin"
    destdir('../bin').mkdir
    destdir('../bin').install workdir('puppet'), 'puppet'
    destdir('../bin').install workdir('omnibus.bin'), 'facter'
    destdir('../bin').install workdir('omnibus.bin'), 'hiera'
    destdir('../bin').install builddir('../unicorn'), 'unicorn'

    destdir('../var').mkdir
    destdir('../var/lib').mkdir
    destdir('../var/lib/ruby').mkdir
    destdir('../var/lib/ruby').install builddir('../seppuku_patch.rb')
    destdir('../var/lib/ruby').install builddir('../puppet_autoload_patch.rb')
    destdir('../var/lib/ruby').install builddir('../gemspec_patch.rb')
    destdir('../var/lib/puppetmaster').mkdir
    destdir('../var/lib/puppetmaster/rack').mkdir
    destdir('../var/lib/puppetmaster/rack').install builddir('../config.ru')

    destdir('../etc').mkdir
    destdir('../etc').install builddir('../unicorn.conf')

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
