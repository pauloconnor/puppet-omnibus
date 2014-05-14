FROM ubuntu:lucid
RUN echo 'deb http://ppa.launchpad.net/git-core/ppa/ubuntu lucid main' >> /etc/apt/sources.list
RUN rm /etc/dpkg/dpkg.cfg.d/02apt-speedup ; apt-get update ; apt-get install screen openjdk-6-jdk openssh-server git build-essential curl wget autoconf bison build-essential libssl-dev libyaml-dev libreadline6 libreadline6-dev zlib1g zlib1g-dev libffi-dev libgdbm-dev libncurses5-dev pkg-config sudo fakeroot libxml2-dev libxslt1-dev libpcre3-dev libsqlite3-dev libgnutls-dev --yes --force-yes ; mkdir /var/run/sshd

#ADD authorized_keys /home/jenkins/.ssh/authorized_keys
RUN useradd jenkins ; chmod 600 /home/jenkins/.ssh/authorized_keys ; chown jenkins: -R /home/jenkins ; chsh -s /bin/bash jenkins


RUN mkdir /package ; mkdir /nail; chown jenkins: /opt /nail ; rm -f /bin/sh ; ln -s /bin/bash /bin/sh ; mkdir /etc/puppet ; mkdir /var/lib/puppet ; mkdir /var/cache/omnibus ; chown jenkins: /var/cache/omnibus /etc/puppet /var/lib/puppet ; touch /etc/default/puppet ;chown jenkins: /etc/default/puppet /package
RUN cd /tmp ; git clone https://github.com/sstephenson/ruby-build ; cd ruby-build ; RUBY_CONFIGURE_OPTS="--without-gdbm --without-dbm" ./bin/ruby-build 1.9.3-p484 /opt/ruby
RUN cd /opt/ruby ; rm -rf /tmp/ruby-build ; ./bin/ruby ./bin/gem install bundler ; ./bin/ruby ./bin/gem install fpm
RUN chown -R jenkins: /opt/ruby

