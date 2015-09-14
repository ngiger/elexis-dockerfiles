#! /bin/bash
cd /opt/elexisfactory
if [ -d "/opt/elexisfactory/elexis-3-core" ]
then
  echo "pull elexis-3-core"
  cd elexis-3-core
  git pull
  cd ..
else
  echo clone elexis-3-core
  git clone https://github.com/elexis/elexis-3-core
fi
cd /opt/elexisfactory/elexis-3-core
git pull
mvn clean install -Dmaven.test.skip=true -Pall-archs
mkdir /opt/elexisfactory/dist
cp -r /opt/elexisfactory/elexis-3-core/ch.elexis.core.p2site/target/products/* /opt/elexisfactory/dist
