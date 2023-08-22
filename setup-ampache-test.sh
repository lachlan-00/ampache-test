#!/bin/sh

AMPACHEDIR=$PWD
COMPOSERPATH="/usr/local/bin/composer"

if [ ! -f $COMPOSERPATH ]; then
  COMPOSERPATH="$AMPACHEDIR/docker/composer"
  wget -q -O $COMPOSERPATH https://getcomposer.org/download/latest-stable/composer.phar
  chmod +x $COMPOSERPATH
fi

if [ ! -d $AMPACHEDIR/ampache ]; then
  git clone -b patch6 https://github.com/ampache/ampache.git ampache
fi
if [ ! -f $AMPACHEDIR/ampache/index.php ]; then
  rm -rf $AMPACHEDIR/ampache
  git clone -b patch6 https://github.com/ampache/ampache.git ampache
fi
cd $AMPACHEDIR/ampache && git reset --hard origin/patch6 && git pull
rm -rf ./composer.lock vendor/* public/lib/components/* && php8.2 $COMPOSERPATH install
php8.2 $COMPOSERPATH install
find . -xtype l -exec rm {} \;
wget -P ./public/lib/components/jQuery-contextMenu/dist/ https://raw.githubusercontent.com/swisnl/jQuery-contextMenu/a7a1b9f3b9cd789d6eb733ee5e7cbc6c91b3f0f8/dist/jquery.contextMenu.min.js.map
wget -P ./public/lib/components/jQuery-contextMenu/dist/ https://raw.githubusercontent.com/swisnl/jQuery-contextMenu/a7a1b9f3b9cd789d6eb733ee5e7cbc6c91b3f0f8/dist/jquery.contextMenu.min.css.map
find . -name "*.map.1" -exec rm {} \;

# create the htaccess files
if [ ! -f $AMPACHEDIR/ampache/public/play/.htaccess ]; then
  cp $AMPACHEDIR/ampache/public/play/.htaccess.dist $AMPACHEDIR/ampache/public/play/.htaccess
fi
if [ ! -f $AMPACHEDIR/ampache/public/rest/.htaccess ]; then
  cp $AMPACHEDIR/ampache/public/rest/.htaccess.dist $AMPACHEDIR/ampache/public/rest/.htaccess
fi

# create the docker volume folders
if [ ! -d $AMPACHEDIR/docker/log ]; then
  mkdir $AMPACHEDIR/docker/log
fi
if [ ! -d $AMPACHEDIR/docker/media ]; then
  mkdir $AMPACHEDIR/docker/media
fi
if [ ! -d $AMPACHEDIR/docker/art ]; then
  mkdir $AMPACHEDIR/docker/art
fi
if [ ! -d $AMPACHEDIR/docker/music ]; then
  mkdir $AMPACHEDIR/docker/music
fi
if [ ! -d $AMPACHEDIR/docker/podcast ]; then
  mkdir $AMPACHEDIR/docker/podcast
fi
if [ ! -d $AMPACHEDIR/docker/upload ]; then
  mkdir $AMPACHEDIR/docker/upload
fi
if [ ! -d $AMPACHEDIR/docker/video ]; then
  mkdir $AMPACHEDIR/docker/video
fi

#copy the config
cp -f $AMPACHEDIR/ampache.cfg.php $AMPACHEDIR/ampache/config/ampache.cfg.php

# reset perms
chown $UID:33 $AMPACHEDIR/docker/log
chmod 775 $AMPACHEDIR/docker/log

chown $UID:33 $AMPACHEDIR/docker/media
chmod 775 $AMPACHEDIR/docker/media

chown $UID:33 $AMPACHEDIR/ampache/composer.json 
chmod 775 $AMPACHEDIR/ampache/composer.json
chown -R $UID:33 $AMPACHEDIR/ampache/config
chmod -R 775 $AMPACHEDIR/ampache/config
chown -R $UID:33 $AMPACHEDIR/ampache/vendor/
chmod -R 775 $AMPACHEDIR/ampache/vendor/
chown -R $UID:33 $AMPACHEDIR/ampache/public/
chmod -R 775 $AMPACHEDIR/ampache/public/

# remove the lock and install composer packages
if [ -f $AMPACHEDIR/ampache/composer.lock ]; then
  rm $AMPACHEDIR/ampache/composer.lock
fi
cd $AMPACHEDIR/ampache && php8.2 $COMPOSERPATH install && cd $AMPACHEDIR


chown $UID:33 $AMPACHEDIR/docker/log
chmod 775 $AMPACHEDIR/docker/log
chown $UID:33 $AMPACHEDIR/docker/media
chmod 775 $AMPACHEDIR/docker/media

chown $UID:33 $AMPACHEDIR/ampache
chmod 775 $AMPACHEDIR/ampache
