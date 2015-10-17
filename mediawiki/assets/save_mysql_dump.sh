#!/bin/bash -v
set -e
/usr/bin/mysqldump -u elexis -h mysql elexis_wiki | gzip -c | cat > /srv/mediawiki/config/mysql_wiki_dump.sql.gz

