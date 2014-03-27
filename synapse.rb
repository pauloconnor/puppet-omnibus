class SynapseRecipe < FPM::Cookery::Recipe
  description 'Puppet tools and support gems'

  name 'synapse'
  version '0.9.1'
  source "https://github.com/airbnb/synapse", :with => :git

  def build
    gem_install "zk", "1.9.4"
    gem_install "docker-api", "1.7.6"
    cleanenv_safesystem "#{destdir}/bin/gem build *.gemspec"
    cleanenv_safesystem "#{destdir}/bin/gem install --no-ri --no-rdoc *.gem"
  end

  def gem_install(name, version = nil)
    v = version.nil? ? '' : "-v #{version}"
    cleanenv_safesystem "#{destdir}/bin/gem install --no-ri --no-rdoc #{v} #{name}"
  end 

  def install
    # Provide 'safe' binaries in /opt/<package>/bin like Vagrant does
    rm_rf "#{destdir}/../bin"
    destdir('../bin').mkdir
    destdir('../bin').install workdir('omnibus.bin'), 'synapse'

    with_trueprefix do
      create_post_install_hook
      create_pre_uninstall_hook
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
BINS="synapse"

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
BINS="synapse"

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
