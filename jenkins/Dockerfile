FROM jenkins:1.625.1

# The following sample Dockerfile uses this option to force use of HTTPS with a certificate included in the image
# COPY https.pem /var/lib/jenkins/cert
# COPY https.key /var/lib/jenkins/pk
# ENV JENKINS_OPTS --httpPort=-1 --httpsPort=8083 --httpsCertificate=/var/lib/jenkins/cert --httpsPrivateKey=/var/lib/jenkins/pk
# EXPOSE 8083

USER root
# Needed to run the elexis tests
RUN apt-get update && apt-get install -y ruby vim maven xvfb ssmtp file

ADD plugins.txt /usr/share/jenkins/ref/

# docker run -p 8080:8080 -p 50000:50000 jenkins
# docker run -p 8080:8080 -p 50000:50000 -v /home/jenkins:/var/jenkins_home --name=jenkins -u 1002 --rm=true jenkins
RUN git config --global user.name "Jenkins"
RUN git config --global user.email "Jenkins@`hostname -f`"

# drop back to the regular jenkins user - good practice
USER jenkins
# s.a. https://jenkins.elexis.info/jenkins/systemInfo für plugins-versionen
