#!/bin/bash
GROUPID=${GROUP_ID:-100}
groupmod -g $GROUPID users
usermod -g $GROUPID root
