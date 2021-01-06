#!/bin/sh
/bin/01_user_config.sh
/bin/02_auto_update.sh

/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
