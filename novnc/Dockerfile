FROM ubuntu:14.04
MAINTAINER Niklaus Giger <niklaus.giger@member.fsf.org>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

# setup our Ubuntu sources (ADD breaks caching)
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main restricted universe multiverse\n\
deb http://archive.ubuntu.com/ubuntu trusty-updates main restricted universe multiverse\n\
deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse\n\
deb http://security.ubuntu.com/ubuntu trusty-security main restricted universe multiverse \n\
"> /etc/apt/sources.list

# no Upstart or DBus
# https://github.com/dotcloud/docker/issues/1724#issuecomment-26294856
RUN apt-mark hold initscripts udev plymouth mountall
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl
RUN apt-get update \
    && apt-get upgrade -y

RUN apt-get install -y python-numpy
RUN apt-get install -y software-properties-common wget
RUN apt-get install -y --force-yes --no-install-recommends supervisor \
        openssh-server pwgen sudo vim-tiny \
        net-tools unzip \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        libreoffice firefox \
        xserver-xorg-video-dummy \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/startup.aux/
RUN echo "#Dummy" > /etc/startup.aux/00.sh
RUN chmod +x /etc/startup.aux/00.sh
RUN mkdir -p /etc/supervisor/conf.d
RUN rm /etc/supervisor/supervisord.conf

# create an ubuntu user
#PASS=`pwgen -c -n -1 10`
#PASS=ubuntu
#echo "User: ubuntu Pass: $PASS"
#RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo ubuntu

# create an ubuntu user who cannot sudo
RUN useradd --create-home --shell /bin/bash --user-group ubuntu
RUN echo "ubuntu:badpassword" | chpasswd

EXPOSE 6080
EXPOSE 5900
EXPOSE 22

ADD openbox-config /openbox-config
RUN cp -r /openbox-config/.config ~ubuntu/
RUN chown -R ubuntu ~ubuntu/.config ; chgrp -R ubuntu ~ubuntu/.config
RUN rm -r /openbox-config

WORKDIR /

############ being Eclipse stuff ###############
# java install
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
# say yes to the oracle license agreement
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
#
RUN apt-get install -y --force-yes oracle-java8-installer
RUN apt-get install -y --force-yes oracle-java8-set-default
#
# eclipse IDE
RUN apt-get install -y desktop-file-utils
RUN apt-get install -y eclipse
############ end Eclipse stuff ###############

# store a password for the VNC service
RUN mkdir /home/root
RUN mkdir /home/root/.vnc
RUN x11vnc -storepasswd foobar /home/root/.vnc/passwd
ADD xorg.conf /etc/X11/xorg.conf

# Add Elexis DemoDB

RUN mkdir -p /opt/elexis && \
    echo 'Installing demoDB' && \
    cd       /opt/elexis && \
    wget --quiet http://download.elexis.info/demoDB/demoDB_3.0_with_administrator.zip -O demoDB.zip

RUN cd /usr/local/bin && \
  wget --quiet http://ftp.fau.de/eclipse/tools/buckminster/products/director_latest.zip && \
  unzip -q director_latest.zip

# Add Elexis 3.1 prerelease
RUN wget --quiet -q --no-check-certificate -O /tmp/elexis.zip https://srv.elexis.info/jenkins/view/3.0/job/Elexis-3.0-Core/lastSuccessfulBuild/artifact/ch.elexis.core.p2site/target/products/ch.elexis.core.application.ElexisApp-linux.gtk.x86_64.zip
RUN  cd       /opt/elexis &&  echo 'Installing elexis' && unzip -uq /tmp/elexis.zip && rm /tmp/elexis.zip
RUN sudo -u ubuntu sh -c "mkdir -v /home/ubuntu/elexis && cd /home/ubuntu/elexis && unzip -uq /opt/elexis/demo*.zip && ls -laRrt /home/ubuntu/elexis"

RUN /usr/local/bin/director/director \
  -destination /opt/elexis \
  -repository http://download.elexis.info/elexis.3.core/prerelease/ \
  -repository http://download.elexis.info/elexis.3.base/prerelease/ \
  -application org.eclipse.equinox.p2.director \
  -installIU ch.elexis.base.ch.feature.feature.group \
  -installIU org.iatrix.feature.feature.group \
  -installIU ch.elexis.omnivore.feature.feature.group \
  -installIU ch.elexis.base.ch.legacy.feature.feature.group \
  -installIU com.hilotec.elexis.opendocument.feature.feature.group \
  -installIU com.hilotec.elexis.kgview.feature.feature.group \
  -installIU com.hilotec.elexis.messwerte.v2.feature.feature.group \
  -installIU ch.elexis.agenda.feature.feature.group \
  -installIU ch.medelexis.text.templator.feature.feature.group

# noVNC
ENTRYPOINT ["/startup.sh"]
ADD startup.sh /
ADD supervisord.conf.xorg /etc/supervisor/supervisord.conf
ADD assets/run /usr/local/bin/elexis-3
ADD assets/*.png /usr/share/icons/
ADD assets/*.desktop /usr/share/applications/

ADD noVNC /noVNC/


