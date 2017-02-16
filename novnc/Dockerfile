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
RUN apt-get update && apt-get install -y software-properties-common wget
RUN add-apt-repository ppa:openjdk-r/ppa -y
RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y --force-yes --no-install-recommends \
    python-numpy openjdk-8-jdk  software-properties-common wget supervisor \
        openssh-server pwgen sudo vim-tiny \
        net-tools unzip \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        libreoffice firefox \
        xserver-xorg-video-dummy desktop-file-utils eclipse

RUN locale-gen it_CH.UTF-8 && \
    locale-gen fr_CH.UTF-8 && \
    locale-gen de_CH.UTF-8 \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/startup.aux/
RUN echo "#Dummy" > /etc/startup.aux/00.sh
RUN chmod +x /etc/startup.aux/00.sh
RUN mkdir -p /etc/supervisor/conf.d
RUN rm /etc/supervisor/supervisord.conf

# create an ubuntu user who cannot sudo
RUN useradd --create-home --shell /bin/bash --user-group ubuntu
RUN echo "ubuntu:badpassword" | chpasswd

EXPOSE 6080
EXPOSE 5900
EXPOSE 22

ADD openbox-config /openbox-config
RUN cp -r /openbox-config/.config ~ubuntu/ \
    && chown -R ubuntu ~ubuntu/.config ; chgrp -R ubuntu ~ubuntu/.config \
    && rm -r /openbox-config \
    && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

WORKDIR /

# store a password for the VNC service
RUN mkdir /home/root \
    && mkdir /home/root/.vnc \
    && x11vnc -storepasswd foobar /home/root/.vnc/passwd
ADD xorg.conf /etc/X11/xorg.conf

# noVNC
ENTRYPOINT ["/startup.sh"]
ADD startup.sh /
ADD supervisord.conf.xorg /etc/supervisor/supervisord.conf
ADD assets/run /usr/local/bin/elexis-3
ADD assets/*.png /usr/share/icons/
ADD assets/*.desktop /usr/share/applications/

ADD noVNC /noVNC/

# Add Elexis DemoDB

RUN mkdir -p /opt/elexis && \
    echo 'Installing demoDB' && \
    cd       /opt/elexis && \
    wget --quiet http://download.elexis.info/demoDB/demoDB_3.0_with_administrator.zip -O demoDB.zip

RUN cd /usr/local/bin && \
  wget --quiet http://ftp.fau.de/eclipse/tools/buckminster/products/director_latest.zip && \
  unzip -q -d /usr/local/bin /usr/local/bin/director_latest.zip

# Add Elexis 3.1 prerelease from i18n
# outout of git ls-remote --heads https://github.com/ngiger/elexis-3-core refs/heads/i18n|cut -f1
RUN echo "head core is 5f4c41c37406a952ebf27172f6c912ef6534d33c" && \
    echo "head base is 76b9ee33be57a4b8ca58bdd1d6d9f36e83361ad0"

RUN mkdir -p /opt/downloads && \
    wget --quiet -q --no-check-certificate -O /opt/downloads/elexis-app.zip \
      https://srv.elexis.info/jenkins/view/3.0/job/Elexis-3.0-Core-ngiger/lastSuccessfulBuild/artifact/ch.elexis.core.p2site/target/products/ch.elexis.core.application.ElexisApp-linux.gtk.x86_64.zip && \
    wget --quiet -q --no-check-certificate -O /opt/downloads/elexis-base.zip \
      https://srv.elexis.info/jenkins/view/3.0/job/Elexis-3.0-Base-ngiger/lastSuccessfulBuild/artifact/ch.elexis.base.p2site/target/repository/*zip*/repository.zip

RUN mkdir -p /opt/downloads/elexis-base \
  && unzip -q -d /opt/downloads/elexis-base /opt/downloads/elexis-base.zip \
  && unzip -q -d /opt/elexis /opt/downloads/elexis-app.zip \
  && unzip -qu -d /home/ubuntu/elexis /opt/elexis/demo*.zip \
  && chown -R ubuntu:ubuntu /home/ubuntu \
  && /usr/local/bin/director/director \
    -destination /opt/elexis \
    -repository file:///opt/downloads/elexis-base/repository \
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


