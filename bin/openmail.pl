#!/usr/bin/perl

$addr = shift @ARGV;
@args = ( '-remote' , 'mailto(' . $addr . ')');
system( 'mozilla-thunderbird' , @args );
