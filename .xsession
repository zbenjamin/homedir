#!/bin/bash
# read in environment variables and then run the normal session manager
[ -r /etc/profile ] && source /etc/profile
[ -r ~/.bash_profile ] && source ~/.bash_profile

[ -x /usr/bin/afuse ] && afuse -o mount_template='sshfs -o reconnect -o workaround=rename %r:/ %m' -o unmount_template='fusermount -u -z %m' ~/sshfs

x-session-manager

[ -x /usr/bin/afuse ] && fusermount -u -z ~/sshfs/