class Ruby212 < FPM::Cookery::Recipe
  description 'The Ruby virtual machine'

  name 'ruby'
  version '2.1.2'
  revision 1
  homepage 'http://www.ruby-lang.org/'
  source '', :with => :noop

  maintainer '<maksym@yelp.com>'
  vendor     'fpm'
  license    'The Ruby License'

  section 'interpreters'

  platforms [:ubuntu, :debian] do
    build_depends 'git-core'
  end

  platforms [:fedora, :redhat, :centos] do
    build_depends 'git'
  end

  def build
    safesystem %Q{
      git clone https://github.com/sstephenson/ruby-build.git; \
      ruby-build/bin/ruby-build 2.1.2 #{destdir}; \
      find #{destdir} -name '*.so' -or -name '*.so.*' | xargs strip; \
      rm -rf ruby-build }
  end

  def install
  end

  def patch_ruby
    system(%Q{
      for patch in #{workdir('ruby')}/#{version}/*; do
        echo "Applying $patch..."
        cat $patch | patch -p1 > /dev/null
      done
    })
  end
end
