#!/bin/bash

export DEBIAN_FRONTEND="noninteractive"
usermod -g 0 -G www-data www-data

# user config
cat <<'EOT' > /etc/my_init.d/01_user_config.sh
#!/bin/bash

USERID=${USER_ID:-99}
GROUPID=${GROUP_ID:-100}
groupmod -g $GROUPID www-data
usermod -u $USERID www-data
usermod -g 0 -G www-data www-data
EOT

# Twonkyserver
mkdir -p /etc/service/twonky
mkdir -p /config
cat <<'EOT' > /etc/service/twonky/run
#!/bin/bash
exec /sbin/setuser www-data /usr/local/twonky/twonkyserver -appdata "/config"
EOT

chmod -R +x /etc/service/ /etc/my_init.d/

apt-get update -qq
apt-get install -qy wget unzip  xz-utils

TWONKY_URL=$(curl -sL http://twonky.com/downloads/ | sed -nr 's#.*href="(.+?/twonky-i686-glibc-.+?\.zip)".*#\1#p')
TWONKY_VERSION=$(echo $TWONKY_URL | sed -nr 's#.*twonky-i686-glibc-.+?-(.+?)\.zip.*#\1#p')
TWONKY_URL=$(curl -sL http://twonkyforum.com/downloads/$TWONKY_VERSION/ | sed -nr 's#.*href="(twonky-x86-64-glibc-.+?\.zip)".*#http://twonkyforum.com/downloads/'$TWONKY_VERSION'/\1#p')
TWONKY_ZIP=/tmp/twonkyserver_$TWONKY_VERSION.zip
TWONKY_DIR=/usr/local/twonky

wget -q https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz -O /tmp/ffmpeg.tar.xz
wget -q "$TWONKY_URL" -O $TWONKY_ZIP
if [ $? -eq 0 ]; then
    mkdir -p $TWONKY_DIR
    unzip -d $TWONKY_DIR -o $TWONKY_ZIP
    rm -f $TWONKY_ZIP
    chmod -R +x $TWONKY_DIR
    chown -R www-data:www-data /config
    chmod 770 /config
    tar -C /tmp/ -xvf /tmp/ffmpeg.tar.xz
    cd /tmp/ffmpeg* 
    rm -R manpages
    cp * $TWONKY_DIR/cgi-bin/
fi

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /tmp/*
