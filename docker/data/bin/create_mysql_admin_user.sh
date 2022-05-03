#!/bin/bash

mysqld_safe &
sleep 5

RET=1
while [[ $RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

MYUSER="ampachetest"
MYPASS="ampachetest"
ROOTPASS="none"

echo "CREATE USER '$MYUSER'@'localhost' IDENTIFIED BY '$MYPASS';"
mysql -uroot -e "CREATE USER '$MYUSER'@'localhost' IDENTIFIED BY '$MYPASS';"
echo "CREATE DATABASE ampachetest;"
mysql -uroot -e "CREATE DATABASE ampachetest;"
echo "ampachetest < /var/lib/mysql/ampache-test.sql"
mysql -uroot ampachetest < /var/lib/mysql/ampache-test.sql
echo "GRANT ALL PRIVILEGES ON *.* TO '$MYUSER'@'localhost' WITH GRANT OPTION;"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '$MYUSER'@'localhost' WITH GRANT OPTION;"

if [ ! "$ROOTPASS" = "none" ]; then
  echo ""
  mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOTPASS';"
fi
