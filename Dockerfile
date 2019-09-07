FROM ubuntu:bionic

# Set correct environment variables
ENV DEBIAN_FRONTEND="noninteractive" HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
ENV supervisor_conf /etc/supervisor/supervisord.conf
ENV start_scripts_path /bin

# Update packages from baseimage
RUN apt-get update -qq
# Install and activate necessary software
RUN apt-get upgrade -qy && apt-get install -qy \
    apt-utils \
    cron \
    supervisor \
    ssl-cert \
    wget \
    unzip \
    xz-utils \
    sudo \
    && mkdir -p /etc/service/twonky \
    && mkdir -p /config \
    && wget -q https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -O /tmp/ffmpeg.tar.xz \
    && wget -q http://download.twonky.com/8.5.1/twonky-x86-64-glibc-2.22-8.5.1.zip -O /tmp/twonkyserver.zip \
    && mkdir -p /usr/local/twonky \
    && unzip -d /usr/local/twonky -o /tmp/twonkyserver.zip \
    && rm -f /tmp/twonkyserver.zip \
    && chmod -R +x /usr/local/twonky \
    && chown -R root:users /config \
    && chmod 770 /config \
    && tar -C /tmp/ -xvf /tmp/ffmpeg.tar.xz \
    && cd /tmp/ffmpeg* \
    && rm -R manpages \
    && cp -R * /usr/local/twonky/cgi-bin/ \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /tmp/* \
    && usermod -a -G users root

COPY supervisord.conf ${supervisor_conf}
COPY 01_user_config.sh ${start_scripts_path}
COPY 02_auto_update.sh ${start_scripts_path}

COPY start.sh /start.sh
RUN chmod +x ${start_scripts_path}/01_user_config.sh \
    && chmod +x ${start_scripts_path}/02_auto_update.sh \
    && chmod +x /start.sh

CMD ["/start.sh"]

VOLUME /config
VOLUME /data

EXPOSE 1030/udp 1900/udp 9000/tcp
