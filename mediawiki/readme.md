# A Debian(Jessie)-based mediawiki Docker container

## Setup

Create directories for configuration and images (if you want to enable uploads)
and make the images directory writable for the nginx image, e.g. like this:

    mkdir /srv/mediawiki/config /srv/mediawiki/images
    chown www-data /srv/mediawiki/images

In the dockerfile I specified some extension I use for wiki.elexis.info.

## Running mediawiki

Run the image like this:

    docker run -d -e MEDIAWIKI_DB_NAME=test_wiki -e MEDIAWIKI_DB_USER=test_wiki_user \
      -e MEDIAWIKI_DB_PASSWORD=very-secure -v /srv/test_wiki/config:/srv/mediawiki/config \
      -v /srv/test_wiki/images:/srv/mediawiki/images --link=hopeful_mclean:mysql
      -p 8080:80 fqxp/mediawiki

This will start a web server on the server port 8080 which is accessible via the
URL `http://localhost:8080`.

To install the database tables and create `LocalSettings.php`, configure
MediaWiki at `http://localhost:8080/mw-config/index.php`

Page URLs will have the form `http://localhost:8080/w/Page_Name`.

### Environment variables

These are the environment variables needed to run mediawiki:

- `MEDIAWIKI_DB_NAME`: MySQL database name to use
- `MEDIAWIKI_DB_USER`: MySQL username to use
- `MEDIAWIKI_DB_PASSWORD`: MySQL user password

### Load/create a dump

The dumps goes into /srv/mediawiki/config, which should be mounted somewhere

    docker exec $WIKI_CONTAINER_ID /usr/local/bin/load_mysql_dump.sh
    docker exec $WIKI_CONTAINER_ID /usr/local/bin/save_mysql_dump.sh

### Thanks

Thanks to Frank Ploss. I could use many ideas from his project under https://github.com/fqxp/dockerfiles/tree/master/mediawiki


## Debugging

We run everything locally here using commands, saving LocalConfig.php in assets/{version} and building with
docker build -t wiki/{version} .
The container is run

    docker run -rm \
      -e MAWIKI_DB_NAME=elexis_wiki -e MEDIAWIKI_DB_USER=elexis \
      -e MEDIAWIKI_DB_PASSWORD=elexisTest \
      -v /home/elexis//mediawiki/config:/srv/mediawiki/images \
      -v /home/elexis//mediawiki/config:/srv/mediawiki/images \
      -l srvelexisinfo_wikidb_1 \
      wiki:{version}

To load the original dump run docker exec wiki:{version} /bin/bash and call

    zat /srv/mediawiki/config/mysql_wiki_dump.sql.gz | /usr/bin/mysql -u elexis -h mysql elexis_wiki
    bzcat /srv/mediawiki/config/mysql_wiki_dump_20150905-073654.sql.bz2 | /usr/bin/mysql -u elexis -h 172.17.0.166 elexis_wiki