node "precise" {
  Exec {
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/ruby/bin/"
  }

  exec {"apt-get update":} ->
  package {"git": ensure => installed} ->
  exec {"gem install /vagrant/vendor/bundler-1.6.3.gem":} ->
  exec {"bundle install --local": cwd => "/vagrant", user => "vagrant"}

  file {"/tmp/build": ensure => directory, purge => true} ->
  file {"/vagrant/tmp-build": ensure => link, target => "/tmp/build"}

  file {"/tmp/dest": ensure => directory, purge => true} ->
  file {"/vagrant/tmp-dest": ensure => link, target => "/tmp/dest"}
}

node "centos6" {
  package {"ruby": ensure => installed}
  package {"git":  ensure => installed}
}
