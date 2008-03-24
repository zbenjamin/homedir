#!/usr/bin/perl

$url = shift @ARGV;

# gnome-terminal bug?
if ($url =~ m/^http:(?!\/\/)/i) {
  $url =~ s/^http://;
}

# the URL must now start with a protocol
if ($url !~ m/^(https?|ftp):\/\//i) {
  $url = 'http://' . $url;
}

#print "url: $url\n";

@args = ( '-new-tab', $url);
system( '/usr/bin/firefox' , @args );

if ($? == -1) {
  print "failed to execute: $!\n";
  exit 1;
} elsif ($? & 127) {
  printf "child died with signal %d, %s coredump\n",
    ($? & 127),  ($? & 128) ? 'with' : 'without';
  exit 1;
} elsif (($? >> 8) != 0) {
  printf "child exited with value %d\n", $? >> 8;
  exit 1;
}
