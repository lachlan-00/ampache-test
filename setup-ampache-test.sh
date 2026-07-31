#!/bin/sh

AMPACHETESTDIR=$PWD
COMPOSERPATH="/usr/local/bin/composer"
DEVELOPBRANCH="develop"

if [ ! -f $COMPOSERPATH ]; then
  COMPOSERPATH="$AMPACHETESTDIR/docker/composer"
  wget -q -O $COMPOSERPATH https://getcomposer.org/download/latest-stable/composer.phar
  chmod +x $COMPOSERPATH
fi

if [ ! -d $AMPACHETESTDIR/ampache ]; then
  git clone -b $DEVELOPBRANCH https://github.com/ampache/ampache.git ampache
fi
if [ ! -f $AMPACHETESTDIR/ampache/index.php ]; then
  rm -rf $AMPACHETESTDIR/ampache
  git clone -b $DEVELOPBRANCH https://github.com/ampache/ampache.git ampache
fi
cd $AMPACHETESTDIR/ampache && git fetch origin $DEVELOPBRANCH && git checkout -f $DEVELOPBRANCH && git reset --hard origin/$DEVELOPBRANCH && git pull
rm -rf ./composer.lock vendor/* public/lib/components/*

php $COMPOSERPATH install
npm install
npm run build

find . -xtype l -exec rm {} \;
wget -P ./public/lib/components/jQuery-contextMenu/dist/ https://raw.githubusercontent.com/swisnl/jQuery-contextMenu/a7a1b9f3b9cd789d6eb733ee5e7cbc6c91b3f0f8/dist/jquery.contextMenu.min.js.map
wget -P ./public/lib/components/jQuery-contextMenu/dist/ https://raw.githubusercontent.com/swisnl/jQuery-contextMenu/a7a1b9f3b9cd789d6eb733ee5e7cbc6c91b3f0f8/dist/jquery.contextMenu.min.css.map
find . -name "*.map.1" -exec rm {} \;

# create the htaccess files
if [ ! -f $AMPACHETESTDIR/ampache/public/play/.htaccess ]; then
  cp $AMPACHETESTDIR/ampache/public/play/.htaccess.dist $AMPACHETESTDIR/ampache/public/play/.htaccess
fi
if [ ! -f $AMPACHETESTDIR/ampache/public/rest/.htaccess ]; then
  cp $AMPACHETESTDIR/ampache/public/rest/.htaccess.dist $AMPACHETESTDIR/ampache/public/rest/.htaccess
fi

# create the docker volume folders
if [ ! -d $AMPACHETESTDIR/docker/log ]; then
  mkdir $AMPACHETESTDIR/docker/log
fi
if [ ! -d $AMPACHETESTDIR/docker/media ]; then
  mkdir $AMPACHETESTDIR/docker/media
fi
if [ ! -d $AMPACHETESTDIR/docker/art ]; then
  mkdir $AMPACHETESTDIR/docker/art
fi
if [ ! -d $AMPACHETESTDIR/docker/music ]; then
  mkdir $AMPACHETESTDIR/docker/music
fi
if [ ! -d $AMPACHETESTDIR/docker/podcast ]; then
  mkdir $AMPACHETESTDIR/docker/podcast
fi
if [ ! -d $AMPACHETESTDIR/docker/upload ]; then
  mkdir $AMPACHETESTDIR/docker/upload
fi
if [ ! -d $AMPACHETESTDIR/docker/video ]; then
  mkdir $AMPACHETESTDIR/docker/video
fi

#copy the config
cp -f $AMPACHETESTDIR/ampache.cfg.php $AMPACHETESTDIR/ampache/config/ampache.cfg.php

# reset perms
chown $UID:33 $AMPACHETESTDIR/docker/log
chmod 775 $AMPACHETESTDIR/docker/log

chown $UID:33 $AMPACHETESTDIR/docker/media
chmod 775 $AMPACHETESTDIR/docker/media

chown $UID:33 $AMPACHETESTDIR/ampache/composer.json 
chmod 775 $AMPACHETESTDIR/ampache/composer.json
chown -R $UID:33 $AMPACHETESTDIR/ampache/config
chmod -R 775 $AMPACHETESTDIR/ampache/config
chown -R $UID:33 $AMPACHETESTDIR/ampache/vendor/
chmod -R 775 $AMPACHETESTDIR/ampache/vendor/
chown -R $UID:33 $AMPACHETESTDIR/ampache/public/
chmod -R 775 $AMPACHETESTDIR/ampache/public/

# remove the lock and install composer packages
if [ -f $AMPACHETESTDIR/ampache/composer.lock ]; then
  rm $AMPACHETESTDIR/ampache/composer.lock
fi
cd $AMPACHETESTDIR/ampache && php $COMPOSERPATH install && cd $AMPACHETESTDIR


chown $UID:33 $AMPACHETESTDIR/docker/log
chmod 775 $AMPACHETESTDIR/docker/log
chown $UID:33 $AMPACHETESTDIR/docker/media
chmod 775 $AMPACHETESTDIR/docker/media

chown $UID:33 $AMPACHETESTDIR/ampache
chmod 775 $AMPACHETESTDIR/ampache
