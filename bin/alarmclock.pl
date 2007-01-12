#!/usr/bin/env perl

use warnings;
use strict;

my $time1 = shift;
my $time2 = shift;

system("echo 'dcop --user zev --all-sessions amarok player play' | at $time1");

if (defined $time2) {
  system("echo 'dcop --user zev --all-sessions amarok player stop' | at $time2");
}
