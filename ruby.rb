class Ruby193 < FPM::Cookery::Recipe
  description 'The Ruby virtual machine'

  name 'ruby'
  version '1.9.3.484'
  revision 1
  homepage 'http://www.ruby-lang.org/'
  source 'http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p484.tar.bz2'
  sha256 '0fdc6e860d0023ba7b94c7a0cf1f7d32908b65b526246de9dfd5bb39d0d7922b'

  maintainer '<github@tinycat.co.uk>'
  vendor     'fpm'
  license    'The Ruby License'

  section 'interpreters'

  rel = `cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d= -f2`.chomp

  platforms [:ubuntu, :debian] do
    build_depends 'autoconf',
                  'libreadline6-dev',
                  'bison',
                  'zlib1g-dev',
                  'libssl-dev',
                  'libncurses5-dev',
                  'build-essential',
                  'libffi-dev',
                  'libgdbm-dev'
    case rel
    when 'lucid'
      depends 'libffi5', 'libssl0.9.8'
    else
      depends 'libffi6', 'libssl1.0.0', 'libtinfo5'
    end
    depends 'libncurses5',
            'libreadline6',
            'zlib1g',
            'libgdbm3'
  end

  platforms [:fedora, :redhat, :centos] do
    build_depends 'rpmdevtools',
                  'libffi-devel',
                  'autoconf',
                  'bison',
                  'libxml2-devel',
                  'libxslt-devel',
                  'openssl-devel',
                  'gdbm-devel'
    depends 'zlib',
            'libffi',
            'gdbm'
  end
  platforms [:fedora] do depends.push('openssl-libs') end
  platforms [:redhat, :centos] do depends.push('openssl') end

  def build
    ENV['RUBY_CFLAGS'] = "-O3 -Wno-error=shorten-64-to-32 -march=native #{ENV['RUBY_CFLAGS']}"
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
end

