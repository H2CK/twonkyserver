#!/bin/bash
UPDT_ON_START=${UPDATE_ON_START:-FALSE}
if [ "$UPDT_ON_START" = "TRUE" ]
then
apt-get update -q >> /proc/1/fd/1 
apt-get upgrade -qy >> /proc/1/fd/1 
fi
