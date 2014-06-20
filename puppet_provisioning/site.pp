node "precise" {
  exec {"/usr/bin/apt-get update":} ->
  package {"ruby1.9.3": ensure => installed} ->
  package {"git": ensure => installed}
}

node "centos6" {
  package {"ruby": ensure => installed}
  package {"git":  ensure => installed}
}
