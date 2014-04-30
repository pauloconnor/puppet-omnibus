FROM backjlack/centos:5.9
RUN yum install java openssh-server screen -y ; mkdir /var/run/sshd
RUN wget http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
RUN wget http://rpms.famillecollet.com/enterprise/remi-release-5.rpm
RUN rpm -Uvh remi-release-5*.rpm epel-release-5*.rpm
RUN adduser jenkins -g root ; adduser puppet ; mkdir /home/jenkins/.ssh ; chown jenkins: /home/jenkins/.ssh ; chmod 700 /home/jenkins/.ssh
ADD authorized_keys /home/jenkins/.ssh/authorized_keys
RUN chmod 600 /home/jenkins/.ssh/authorized_keys ; chown jenkins: /home/jenkins/.ssh/authorized_keys
RUN /etc/init.d/sshd start ; /etc/init.d/sshd stop
RUN sed -i -e's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
RUN rpm -Uvh http://repo.webtatic.com/yum/centos/5/latest.rpm
RUN yum install --enablerepo=webtatic git-all -y
RUN yum install make gcc-c++ pcre-devel glibc-headers openssl-devel readline libyaml-devel readline-devel zlib zlib-devel rpmdevtools libffi-devel bison libxslt-devel gdbm-devel rpmdevtools gnutls-devel -y
RUN rpm -Uvh ftp://ftp.pbone.net/mirror/dl.iuscommunity.org/pub/ius/archive/Redhat/5/i386/autoconf26x-2.63-4.ius.el5.noarch.rpm
RUN mkdir /opt ; mkdir /nail; chown jenkins: /opt /nail ; yum install sudo fakeroot -y
RUN mkdir /package ; mkdir /etc/puppet ; mkdir /var/lib/puppet ; mkdir /var/cache/omnibus ; chown jenkins: /etc/puppet /var/lib/puppet /var/cache/omnibus /package
RUN touch /etc/sysconfig/puppet ;chown jenkins: /etc/sysconfig/puppet
RUN cd /tmp ; git clone https://github.com/sstephenson/ruby-build ; cd ruby-build ; RUBY_CONFIGURE_OPTS="--without-gdbm --without-dbm" ./bin/ruby-build 1.9.3-p484 /opt/ruby
RUN cd /opt/ruby ; rm -rf /tmp/ruby-build ; ./bin/ruby ./bin/gem install bundler ; ./bin/ruby ./bin/gem install fpm

