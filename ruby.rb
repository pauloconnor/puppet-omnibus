class Ruby212 < FPM::Cookery::Recipe
  description 'The Ruby virtual machine'

  name 'ruby'
  version '2.1.2'
  revision 545
  homepage 'http://www.ruby-lang.org/'
  source 'http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.bz2'
  sha256 '6948b02570cdfb89a8313675d4aa665405900e27423db408401473f30fc6e901'

  maintainer '<github@tinycat.co.uk>'
  vendor     'fpm'
  license    'The Ruby License'

  section 'interpreters'

  platforms [:ubuntu, :debian] do
    build_depends 'autoconf', 'bison', 'zlib1g-dev', 'libssl-dev',
                  'libncurses5-dev', 'build-essential', 'libgdbm-dev'

    case `cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d= -f2`.chomp
    when 'hardy'
      build_depends 'libffi4-dev', 'libreadline5-dev'
      depends 'libreadline5', 'libffi4', 'libssl0.9.8'
    when 'lucid'
      build_depends 'libffi-dev', 'libreadline6-dev'
      depends 'libreadline6', 'libffi5', 'libssl0.9.8'
    else
      build_depends 'libffi-dev', 'libreadline6-dev'
      depends 'libreadline6', 'libffi6', 'libssl1.0.0', 'libtinfo5'
    end

    depends 'libncurses5', 'zlib1g', 'libgdbm3'
  end

  platforms [:fedora, :redhat, :centos] do
    build_depends 'rpmdevtools', 'libffi-devel', 'bison', 'libxml2-devel',
                  'libxslt-devel', 'openssl-devel', 'gdbm-devel'
    depends 'zlib', 'libffi', 'gdbm'

    if IO.read('/etc/redhat-release') =~ /CentOS release 5/
      build_depends 'autoconf26x'
    else
      puts "USING JUST autoconf"
      build_depends 'autoconf'
    end
  end

  platforms([:fedora]) { depends.push('openssl-libs') }
  platforms([:redhat, :centos]) { depends.push('openssl') }

  def build
    patch_ruby

    ENV['CFLAGS'] = "-Os #{ENV['CFLAGS']}"
    system "autoconf2.6x || autoconf"
    configure :prefix => destdir,
              'enable-shared' => true,
              'disable-install-doc' => true,
              'disable-pthread' => true,
              'with-opt-dir' => destdir
    make
  end

  def install
    make :install
    # Shrink package.
    rm_f "#{destdir}/lib/libruby-static.a"
    safesystem "strip #{destdir}/bin/ruby"
    safesystem "find #{destdir} -name '*.so' -or -name '*.so.*' | xargs strip"
  end

  def patch_ruby
    system(%Q{
      for patch in #{workdir('ruby-patches')}/#{version}/*; do
        echo "Applying $patch..."
        cat $patch | patch -p1 > /dev/null
      done
    })
  end
end
