docker-elexis-novnc
=========================

Based on the work from https://github.com/mccahill/docker-eclipse-novnc +

* installed Elexis 3.1 from prerelease

The user documentation is found under https://wiki.elexis.info/Docker-elexis-novnc


How to build
------------

You have to change demo1.testbed-elexis.dyndns.org to an appropriate domain name in domains.txt.

On testbed-elexis.dyndns.org I installed debian jessie + packages docker, nginx and letsencrypt.sh

configure it here with your fully qualified domain name of your docker container
most probably a subdomain, eg. you might use export FQDN=demo1.`domainname -f`

openssl x509 -text -in noVNC/self.pem | grep -w CN


To test the letsencrypt I changed in the config CA to CA="https://acme-staging.api.letsencrypt.org/directory". Then ran `mkdir /var/www/letsencrypt`

The I added the following snippet to /etc/nginx/sites-enabled/some_server
  location /.well-known/acme-challenge {
    alias /var/www/letsencrypt;
  }
Then I was able to run `letsencrypt.sh -f config --out . -c`, which create various files under /tmp/certs/testbed-elexis.dyndns.org/

openssl x509 -text -in noVNC/self.pem | grep -w CN

http://demo1.testbed-elexis.dyndns.org:6081/vnc_auto.html gibt The connection was reset

After you have a cert in self.pem, build the container with the command
```
docker build -t docker-eclipse-novnc .
```

Run using the default password from the Dockerfile build script:
```
docker run -i -t -p 6081:6080  -h  demo1.testbed-elexis.dyndns.org docker-eclipse-novnc
```

Better yet, run and set the passwords for VNC and user via environment variables like this:

```
sudo docker run -i -t -p 6081:6080 -e UBUNTUPASS=supersecret -e VNCPASS=secret \
  -h demo1.testbed-elexis.dyndns.org docker-eclipse-novnc
```
You need to specify the hostname to the container so that it matches the
site certificate that you configured noVNC with, or pedantic web browsers will
frighten users with scary warnings. 

TO access the app, point your web browser at
    https://demo1.testbed-elexis.dyndns.org:6081/vnc.html
or
    https://demo1.testbed-elexis.dyndns.org:6081/vnc_auto.html

You will be prompted for the vnc password which was set to 'foobar' in the
Dockerfile build. You'll probably want to change that and also change the 
hardcoded password ('badpassword') for the ubuntu account created 
in the build process by specifying passwords when you run the container.

Note that the user can skip the VNC password prompt if you redirect them to 

 https://demo1.testbed-elexis.dyndns.or:6081/vnc.html?&encrypt=1&autoconnect=1&password=elexis

Server disconnected (code: 1000, reason: Target closed)
http://demo.testbed-elexis.dyndns.org:6085/vnc_auto.html

Installed `dcsg: A systemd service generator for docker-compose` from https://github.com/andreaskoch/dcsg.
Ran `./dcsg_linux_amd64 install `inside /opt/src/docker-elexis-novnc

TODO: Encrypted noVNC Sessions
------------------------------
To enable encrypted connections, you need to (at a minimum) create a 
noVNC self.pem certificate file as describe here: 
   https://github.com/kanaka/websockify/wiki/Encrypted-Connections

Even better, get your private key signed by a known certificate authority,
so that users are not confronted with frightening warnings about untrusted sites. 

Note that you may run into trouble if you include the entire CA signing 
chain if you use a CA such as Commodo (at least on Chrome and Safari) so I 
have been running with self.pem containner only the private key and the 
CA signed cert. But Firefox seems to want to see the entire signing chain for certs issued 
by Commodo, or something. So - some work is still needed to get Firefox
to behave, but Safari and Chrome seem to work.

PROTIP: make sure that the read permissions are set to only allow root to read the
self.pem file, since you probably don't want users to get access to the private key.

Misc Notes
----------
The file openbox-config/.config is used to put some reasonable default settings in place for 
the X environment when run inside a web browser. Reasonable means things like placing the dock 
at the top of the page so users don't have to scroll their web page to find it.

Extending
---------

To add scripts to run at startup, add them to this folder, with a ```.sh``` extension:

```
/etc/startup.aux/
```

To add supervisord configs, add them to this folder:
```
/etc/supervisor/conf.d/
```

## TODO:

* security
* Set homepage of firefox https://wiki.elexis.info/Start_mit_Elexis
* terminal does not accept accented character. Umlauts work in elexis
* Add letsencrypt certificate