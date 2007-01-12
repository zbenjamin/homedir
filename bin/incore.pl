#!/usr/bin/env perl
use strict;
use warnings;

use Module::CoreList;

my $module = shift
 or die("Usage: $0 [module] [version]");
my $version = shift || 0;

my $first = Module::CoreList->first_release($module, $version);

if($first) {
    print "$first\n";
} else {
    print "Not in core.\n";
}
