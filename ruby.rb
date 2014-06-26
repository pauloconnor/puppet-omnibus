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

  def build
    safesystem "tar -zxf #{workdir('vendor/ruby-build-20140524.tar.gz')} -C /tmp"
    safesystem "/tmp/ruby-build-20140524/bin/ruby-build -v 2.1.2 #{destdir}"
    safesystem "find #{destdir} -name '*.so' -or -name '*.so.*' -exec strip {} \\;"
    safesystem "rm -rf /tmp/ruby-build-20140524"
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
