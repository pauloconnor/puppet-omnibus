class Ruby212 < FPM::Cookery::Recipe
  description 'The Ruby virtual machine'

  name 'ruby'
  version '2.1.2'
  revision 1
  homepage 'http://www.ruby-lang.org/'
  source 'nothing', :with => :noop

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
    safesystem "tar -zxf #{workdir('vendor/ruby-build-20140524.tar.gz')} -C /tmp"
    safesystem "/tmp/ruby-build-20140524/bin/ruby-build 2.1.2 #{builddir}"
    safesystem "find #{builddir} -name '*.so' -or -name '*.so.*' | xargs strip"
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
