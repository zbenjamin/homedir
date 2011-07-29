#!/bin/bash
# read in environment variables and then run the normal session manager
[ -r /etc/profile ] && source /etc/profile
[ -r ~/.bash_profile ] && source ~/.bash_profile

autocutsel -fork
autocutsel -selection PRIMARY -fork

[ -x /usr/bin/afuse ] && afuse -o mount_template='sshfs -o reconnect -o workaround=rename %r:/ %m' -o unmount_template='fusermount -u -z %m' ~/sshfs

# to get the new notification system instead of the old one
export GDMSESSION=gnome

x-session-manager

[ -x /usr/bin/afuse ] && fusermount -u -z ~/sshfs/
