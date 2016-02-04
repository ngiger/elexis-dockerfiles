from debian:jessie

env DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y php5-mcrypt php5-sqlite php5-mysql sqlite php5-gd php5-intl imagemagick pwgen mysql-client wget \
    supervisor nginx-light php5-fpm php5-cli curl procps vim git bzip2


ENV MEDIAWIKI_VERSION_MAJOR 1.25
ENV MEDIAWIKI_VERSION_MINOR 2
RUN wget http://releases.wikimedia.org/mediawiki/${MEDIAWIKI_VERSION_MAJOR}/mediawiki-${MEDIAWIKI_VERSION_MAJOR}.${MEDIAWIKI_VERSION_MINOR}.tar.gz && \
 tar xzf mediawiki-${MEDIAWIKI_VERSION_MAJOR}.${MEDIAWIKI_VERSION_MINOR}.tar.gz -C /srv
# or much faster add mediawiki-${MEDIAWIKI_VERSION_MAJOR}.${MEDIAWIKI_VERSION_MINOR}.tar.gz /srv/
# RUN cd /srv && tar xzf mediawiki-${MEDIAWIKI_VERSION_MAJOR}.${MEDIAWIKI_VERSION_MINOR}.tar.gz -C /srv
RUN mv /srv/mediawiki-${MEDIAWIKI_VERSION_MAJOR}.${MEDIAWIKI_VERSION_MINOR} /srv/mediawiki
RUN chown -R www-data /srv/mediawiki/mw-config
RUN ln -sf /srv/mediawiki/config/LocalSettings.php /srv/mediawiki/LocalSettings.php

ADD assets/add_extension.sh /usr/local/bin/add_extension.sh
RUN mkdir -p /srv/mediawiki/downloaded_extensions

# Adapt get_plugins.sh to fetch the extension you want and call it before calling docker build
# the best working combination
# The next steps also unpacks all tar.gz files!
ADD downloaded_extensions/* /srv/mediawiki/extensions/

RUN apt-get update && apt-get install -y acl sudo ssmtp bsd-mailx

ADD site.conf /etc/nginx/sites-enabled/default
RUN echo 'cgi.fix_pathinfo=0' >>/etc/php5/fpm/php.ini
ADD supervisor.conf /etc/supervisor/conf.d/nginx.conf
ADD ./fpm.conf /etc/php5/fpm/php-fpm.conf
ADD ./fpm-pool-www.conf /etc/php5/fpm/pool.d/www.conf
volume  /srv/mediawiki/images
volume /srv/mediawiki/config
volume /srv/www
ADD assets/start_mediawiki assets/save_mysql_dump.sh assets/load_mysql_dump.sh /usr/local/bin/
ADD php-smtp.ini /usr/local/etc/php/conf.d/php-smtp.ini

expose 80
expose 25
env HOME=/root

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

entrypoint ["/usr/local/bin/start_mediawiki"]
cmd ["/usr/bin/supervisord", "--nodaemon"]
