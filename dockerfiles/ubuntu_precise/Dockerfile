FROM ubuntu:precise
RUN rm /etc/dpkg/dpkg.cfg.d/02apt-speedup ; apt-get update ; apt-get install screen libsqlite3-dev openjdk-6-jdk openssh-server git-core build-essential wget curl autoconf bison build-essential libssl-dev libyaml-dev libreadline6 libreadline6-dev zlib1g zlib1g-dev libffi6 libffi-dev libgdbm-dev libncurses5-dev libxslt1-dev libpcre3-dev libgnutls-dev sudo fakeroot pkg-config --yes --force-yes ; mkdir /var/run/sshd
ADD authorized_keys /home/jenkins/.ssh/authorized_keys
RUN useradd jenkins
RUN chmod 600 /home/jenkins/.ssh/authorized_keys ; chown jenkins: -R /home/jenkins
RUN chsh -s /bin/bash jenkins
RUN mkdir /opt ; mkdir /nail; chown jenkins: /opt /nail
RUN rm -f /bin/sh ; ln -s /bin/bash /bin/sh
RUN mkdir /etc/puppet ; mkdir /var/lib/puppet ; mkdir /var/cache/omnibus ; chown jenkins: /etc/puppet /var/lib/puppet /var/cache/omnibus
RUN touch /etc/default/puppet ;chown jenkins: /etc/default/puppet

