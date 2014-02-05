class Nginx < FPM::Cookery::Recipe
  description 'a high performance web server and a reverse proxy server'

  name     'nginx'
  version  '1.5.8'
  revision 2
  homepage 'http://nginx.org/'
  source   "http://nginx.org/download/nginx-#{version}.tar.gz"
  sha1     '5c02b293a59c32172d2d5b3c52da7fe0afc179ef'

  section 'System Environment/Daemons'

  platforms [:ubuntu, :debian] do
    build_depends 'make', 'gcc', 'g++', 'libpcre3-dev', 'zlib1g-dev', 'libssl-dev', 'libxml2-dev', 'libxslt1-dev'

    rel = `cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d= -f2`.chomp
    case rel
    when 'lucid'
      depends 'libssl0.9.8'
    else
      depends 'libssl1.0.0'
    end
    depends 'zlib1g', 'libxml2', 'libxslt1.1'
  end

  platforms [:fedora, :redhat, :centos] do
    build_depends 'gcc', 'gcc-c++', 'make', 'pcre-devel', 'zlib-devel', 'openssl-devel', 'libxml2-devel', 'libxslt-devel'
    depends 'openssl', 'glibc', 'zlib', 'pcre', 'libxslt',
                'perl', 'bash', 'shadow-utils',
                'initscripts', 'chkconfig' 
  end 

  def build
    configure \
      '--with-http_gzip_static_module',
      '--with-http_stub_status_module',
      '--with-http_ssl_module',
      '--with-pcre',
      '--with-file-aio',
      '--with-http_realip_module',
      '--without-http_scgi_module',
      '--without-http_uwsgi_module',
      '--with-http_auth_request_module', # http://nginx.org/en/docs/http/ngx_http_auth_request_module.html
#      '--without-http_fastcgi_module',

      :prefix                     => prefix,

      :user                       => 'puppet',
      :group                      => 'puppet',

      :pid_path                   => '/var/run/puppetmaster-nginx.pid',
      :lock_path                  => '/opt/puppet-omnibus/embedded/var/lock/nginx',
      :conf_path                  => '/opt/puppet-omnibus/etc/nginx.conf',
      :http_log_path              => '/var/log/puppetmaster-nginx/access.log',
      :error_log_path             => '/var/log/puppetmaster-nginx/error.log',
      :http_proxy_temp_path       => '/opt/puppet-omnibus/embedded/var/tmp/proxy',
      :http_fastcgi_temp_path     => '/opt/puppet-omnibus/embedded/var/tmp/fastcgi',
      :http_client_body_temp_path => '/opt/puppet-omnibus/embedded/var/tmp/client_body'
#      :http_uwsgi_temp_path       => '/var/lib/nginx/tmp/uwsgi',
#      :http_scgi_temp_path        => '/var/lib/nginx/tmp/scgi'

    make
  end

  def install
    # startup script
    #(etc/'init.d').install(workdir/'init.d.nginx', 'nginx')
    #(etc/'sysconfig').install(workdir/'sysconfig.nginx', 'nginx')
    #chmod 0755, etc('init.d/nginx')

    # config files
    #(etc/'nginx').install Dir['conf/*']

    # default site
    #(var/'www/nginx-default').install Dir['html/*']

    # server
    destdir('../etc').install builddir('../nginx.conf')
    destdir('../bin').install workdir('omnibus.bin'), 'nginx'
    destdir('bin').install Dir['objs/nginx']

    # man page
    #man8.install Dir['objs/nginx.8']
    #system 'gzip', man8/'nginx.8'

    # support dirs
    %w( var var/lock  var/tmp ).map do |dir|
      destdir(dir).mkpath
    end
  end
end

