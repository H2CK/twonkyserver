#!/bin/bash

export DEBIAN_FRONTEND="noninteractive"
usermod -a -G users root

# user config
cat <<'EOT' > /etc/my_init.d/01_user_config.sh
#!/bin/bash
GROUPID=${GROUP_ID:-100}
groupmod -g $GROUPID users
usermod -g $GROUPID root
EOT

# auto update
cat <<'EOT' > /etc/my_init.d/02_auto_update.sh
#!/bin/bash
apt-get update -qq
apt-get upgrade -qy
EOT

# Twonkyserver
mkdir -p /etc/service/twonky
mkdir -p /config
cat <<'EOT' > /etc/service/twonky/run
#!/bin/bash
exec /sbin/setuser root /usr/local/twonky/twonkyserver -appdata "/config"
EOT

chmod -R +x /etc/service/ /etc/my_init.d/

apt-get update -qq
apt-get install -qy wget unzip  xz-utils

TWONKY_URL=$(curl -sL http://twonky.com/downloads/ | sed -nr 's#.*href="(.+?/twonky-x86-64-glibc-.+?\.zip)".*#\1#p')
TWONKY_VERSION=$(echo $TWONKY_URL | sed -nr 's#.*twonky-x86-64-glibc-.+?-(.+?)\.zip.*#\1#p')
TWONKY_URL=$(curl -sL http://download.twonky.com/$TWONKY_VERSION/ | sed -nr 's#.*href="(twonky-x86-64-glibc-.+?\.zip)".*#http://download.twonky.com/'$TWONKY_VERSION'/\1#p')
TWONKY_ZIP=/tmp/twonkyserver_$TWONKY_VERSION.zip
TWONKY_DIR=/usr/local/twonky

wget -q https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -O /tmp/ffmpeg.tar.xz
wget -q "$TWONKY_URL" -O $TWONKY_ZIP

mkdir -p $TWONKY_DIR
unzip -d $TWONKY_DIR -o $TWONKY_ZIP
rm -f $TWONKY_ZIP
chmod -R +x $TWONKY_DIR
chown -R root:users /config
chmod 770 /config
tar -C /tmp/ -xvf /tmp/ffmpeg.tar.xz
cd /tmp/ffmpeg* 
rm -R manpages
cp * $TWONKY_DIR/cgi-bin/


# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /tmp/*
