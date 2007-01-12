#!/bin/bash
# read in environment variables and then run the normal session manager
[ -r /etc/profile ] && source /etc/profile
[ -r ~/.bash_profile ] && source ~/.bash_profile

exec x-session-manager