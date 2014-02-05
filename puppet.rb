class PuppetGem < FPM::Cookery::Recipe
  description 'Puppet gem stack'

  name 'puppet'
  version '3.0.2'

  source "nothing", :with => :noop

  platforms [:ubuntu, :debian] do
    build_depends 'pkg-config'
    depends 'pkg-config'
  end

  platforms [:fedora, :redhat, :centos] do
    build_depends 'pkgconfig'
    depends 'pkgconfig'
  end

  def build
    # Install gems using the gem command from destdir
    gem_install 'facter',      '1.7.3'
    gem_install 'json_pure',   '1.8.0'
    gem_install 'hiera',       '1.3.0'
    gem_install 'deep_merge',  '1.0.0'
    gem_install 'rgen',        '0.6.5'
    gem_install 'ruby-augeas -- --with-opt-dir=/opt/puppet-omnibus/embedded', '0.4.1'
    gem_install 'ruby-shadow', '2.2.0'
    gem_install 'gpgme',       '2.0.2'
    gem_install 'rack',        '1.5.2'
    gem_install 'unicorn',     '4.8.1'
    gem_install name,          version
    # Download init scripts and conf
    build_files

    # Nasty hack to make puppet be able to use facter 1.7.3
    cleanenv_safesystem "rm -r #{destdir}/lib/ruby/gems/1.9.1/gems/facter-1.6.18 #{destdir}/lib/ruby/gems/1.9.1/cache/facter-1.6.18.gem"
    cleanenv_safesystem "sed -i -e's/1.6.11/1.7.3/' #{destdir}/lib/ruby/gems/1.9.1/specifications/puppet-3.0.2.gemspec"
  end

  def install
    # Install init-script and puppet.conf
    install_files

    # Provide 'safe' binaries in /opt/<package>/bin like Vagrant does
    rm_rf "#{destdir}/../bin"
    destdir('../bin').mkdir
    destdir('../bin').install workdir('omnibus.bin'), 'puppet'
    destdir('../bin').install workdir('omnibus.bin'), 'facter'
    destdir('../bin').install workdir('omnibus.bin'), 'hiera'
    destdir('../bin').install builddir('../unicorn'), 'unicorn'

    destdir('../var').mkdir
    destdir('../var/lib').mkdir
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

echo "Not setting up binstubs to /usr/bin"
exit 0

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
set -e

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
