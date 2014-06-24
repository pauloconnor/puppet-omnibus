FROM ubuntu:precise
RUN rm /etc/dpkg/dpkg.cfg.d/02apt-speedup ; apt-get update ; apt-get install screen libsqlite3-dev openjdk-6-jdk openssh-server git-core build-essential wget curl autoconf bison build-essential libssl-dev libyaml-dev libreadline6 libreadline6-dev zlib1g zlib1g-dev libffi6 libffi-dev libgdbm-dev libncurses5-dev libxslt1-dev libpcre3-dev libgnutls-dev sudo fakeroot pkg-config --yes --force-yes ; mkdir /var/run/sshd

#ADD authorized_keys /home/jenkins/.ssh/authorized_keys
#RUN chmod 600 /home/jenkins/.ssh/authorized_keys ; 
RUN useradd jenkins
RUN mkdir /home/jenkins
RUN chown jenkins: -R /home/jenkins
RUN chsh -s /bin/bash jenkins
RUN mkdir /nail; chown jenkins: /opt /nail
RUN rm -f /bin/sh ; ln -s /bin/bash /bin/sh

RUN mkdir /package ; mkdir /etc/puppet ; mkdir /var/lib/puppet ; mkdir /var/cache/omnibus ; chown jenkins: /etc/puppet /var/lib/puppet /var/cache/omnibus /package
RUN touch /etc/default/puppet ;chown jenkins: /etc/default/puppet
RUN cd /tmp ; git clone https://github.com/sstephenson/ruby-build ; cd ruby-build ; RUBY_CONFIGURE_OPTS="--without-gdbm --without-dbm" ./bin/ruby-build 1.9.3-p484 /opt/ruby
RUN cd /opt/ruby ; rm -rf /tmp/ruby-build
RUN chown -R jenkins: /opt/ruby
