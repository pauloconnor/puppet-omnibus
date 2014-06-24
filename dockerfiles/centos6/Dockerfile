FROM centos:6.4
RUN yum install screen git passwd java-1.7.0-openjdk openssh-server gcc -y ; mkdir /var/run/sshd

RUN adduser jenkins -g root ; adduser puppet ; mkdir /home/jenkins/.ssh ; chown jenkins: /home/jenkins/.ssh ; chmod 700 /home/jenkins/.ssh
#ADD authorized_keys /home/jenkins/.ssh/authorized_keys
#RUN chmod 600 /home/jenkins/.ssh/authorized_keys ; chown jenkins: /home/jenkins/.ssh/authorized_keys
#RUN /etc/init.d/sshd start ; /etc/init.d/sshd stop
#RUN sed -i -e's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
RUN passwd -uf jenkins

RUN yum install gcc-c++ pcre-devel glibc-headers openssl-devel readline libyaml-devel readline-devel zlib zlib-devel rpmdevtools libffi-devel autoconf bison libxslt-devel gdbm-devel gnutls-devel -y
RUN yum install -y libvirt-devel libvirt

RUN mkdir /opt ; mkdir /nail; chown jenkins: /opt /nail ; yum install sudo fakeroot -y
RUN mkdir /package ; mkdir /etc/puppet ; mkdir /var/lib/puppet ; mkdir /var/cache/omnibus ; chown jenkins: /etc/puppet /var/lib/puppet /var/cache/omnibus /package
RUN touch /etc/sysconfig/puppet ;chown jenkins: /etc/sysconfig/puppet
RUN cd /tmp ; git clone https://github.com/sstephenson/ruby-build ; cd ruby-build ; RUBY_CONFIGURE_OPTS="--without-gdbm --without-dbm" ./bin/ruby-build 1.9.3-p484 /opt/ruby
RUN cd /opt/ruby ; rm -rf /tmp/ruby-build
RUN chown -R jenkins: /opt/ruby
