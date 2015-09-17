# See https://github.com/lburgazzoli/lb-docker/blob/master/debian-jessie-java/1.8.0_60/Dockerfile
FROM lburgazzoli/debian-jessie-java:1.8.0_60
MAINTAINER weirich@elexis.ch
RUN apt-get update 
RUN apt-get install -y maven
RUN useradd -m -s /bin/bash elexisbuilder && mkdir /opt/elexisfactory && chown -R elexisbuilder /opt/elexisfactory
ADD build_elexis.sh /home/elexisbuilder/
WORKDIR /home/elexisbuilder
RUN chmod +x build_elexis.sh
USER elexisbuilder
CMD ./build_elexis.sh


