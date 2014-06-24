FROM docker-dev.yelpcorp.com/hardy_yelp
RUN apt-get update 
RUN aptitude -y install screen openjdk-6-jdk openssh-server git build-essential curl wget autoconf bison build-essential libssl-dev libreadline5-dev zlib1g zlib1g-dev libffi4-dev libgdbm-dev libncurses5-dev pkg-config sudo fakeroot libxml2-dev libxslt1-dev libpcre3-dev libsqlite3-dev libgnutls-dev git-core

#ADD authorized_keys /home/jenkins/.ssh/authorized_keys
RUN useradd jenkins ; chmod 600 /home/jenkins/.ssh/authorized_keys ; chown jenkins: -R /home/jenkins ; chsh -s /bin/bash jenkins

RUN mkdir /package ; mkdir /nail; chown jenkins: /opt /nail ; rm -f /bin/sh ; ln -s /bin/bash /bin/sh ; mkdir /etc/puppet ; mkdir /var/lib/puppet ; mkdir /var/cache/omnibus ; chown jenkins: /var/cache/omnibus /etc/puppet /var/lib/puppet ; touch /etc/default/puppet ;chown jenkins: /etc/default/puppet /package

RUN apt-get -y install wget unzip
RUN cd /tmp ; wget --no-check-certificate https://github.com/sstephenson/ruby-build/archive/master.zip 
RUN cd /tmp ; unzip master.zip ; mv ruby-build-master ruby-build

RUN cd /tmp/ruby-build ; RUBY_CONFIGURE_OPTS="--without-gdbm --without-dbm" ./bin/ruby-build 1.9.3-p484 /opt/ruby
RUN cd /opt/ruby ; rm -rf /tmp/ruby-build
RUN chown -R jenkins: /opt/ruby
