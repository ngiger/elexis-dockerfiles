#!/bin/bash -v
set -e
zat /srv/mediawiki/config/mysql_wiki_dump.sql.gz | /usr/bin/mysql -u elexis -h mysql elexis_wiki
bzcat /srv/mediawiki/config/mysql_wiki_dump_20150905-073654.sql.bz2 | /usr/bin/mysql -u elexis -h mysql elexis_wiki

# bunzip2 --stdout $WIKI_LOAD_DUMP | docker exec -it $containerId /usr/bin/mysql -u elexis -h mysql elexis_wiki"
