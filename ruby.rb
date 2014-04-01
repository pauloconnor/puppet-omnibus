class Ruby193 < FPM::Cookery::Recipe
  description 'The Ruby virtual machine'

  name 'ruby'
  version '1.9.3.545'
  revision 545
  homepage 'http://www.ruby-lang.org/'
  source 'http://cache.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p545.tar.bz2'
  sha256 '2533de9f56d62f11c06a02dd32b5ab6d22a8f268c94b8e1e1ade6536adfd1aab'

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
  platforms [:fedora] { depends.push('openssl-libs') }
  platforms [:redhat, :centos] { depends.push('openssl') }

  def build
    patch_ruby

    ENV['CFLAGS'] = "-O3 #{ENV['CFLAGS']}"
    system "autoconf"
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
    repo = "https://raw.githubusercontent.com/keymone/rvm-patchsets/master"
    ruby = "1.9.3/p545"
    system(%Q{
      cat #{workdir('ruby-patchset')} | grep -v '^#' |
      while read patch; do
        echo "Applying $patch..."
        curl #{repo}/patches/ruby/#{ruby}/$patch | patch -p1 > /dev/null
      done
    })
  end
end
