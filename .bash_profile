# ~/.bash_profile: executed by bash(1) for login shells.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/login.defs
#umask 022

# the rest of this file is commented out.

# set variable identifying the chroot you work in
#if [ -f /etc/debian_chroot ]; then
#  debian_chroot=$(cat /etc/debian_chroot)
#fi

# include .bashrc if it exists
#if [ -f ~/.bashrc ]; then
#    . ~/.bashrc
#fi

# set PATH so it includes user's private bin if it exists
if [ -d ~/bin ] ; then
    export PATH=~/bin:"${PATH}"
fi

# do the same with MANPATH
#if [ -d ~/man ]; then
#    MANPATH=~/man:"${MANPATH}"
#    export MANPATH
#fi

export EDITOR=dtemacs
export BROWSER="/home/zev/bin/openurl.pl"
export PYTHONPATH="/home/zev/lib/python2.4:$PYTHONPATH"
export GREP_OPTIONS="--color=auto"
export GTK_IM_MODULE=xim

if [ -e ~/.xmodmap ] ; then
    xmodmap ~/.xmodmap
fi

if [ -e ~/.bash_profile.`hostname` ] ; then
    source ~/.bash_profile.`hostname`
fi