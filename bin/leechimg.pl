#!/usr/bin/perl -w
use HTML::LinkExtor;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use URI::Heuristic;
use Term::ProgressBar;
use Tie::IxHash;

my $raw_url = shift or die "Useage: $0 <url>\n";
my $url = URI::Heuristic::uf_urlstr( $raw_url );
print "Fetching $url...\n";
my $ua = LWP::UserAgent->new( );
$ua->agent( "Mozilla/5.0 (X11;U;Linux 2.4.17 i686)" );

my $req = HTTP::Request->new( GET => $url );
$req->referer( $url );

my $response = $ua->request( $req );

die "Could not fetch url: " . $response->status_line . "\n" if $response->is_error( );
my $content = $response->content( );

my $parser = HTML::LinkExtor->new( undef, $url );
$parser->parse( $content )->eof;
my @links = $parser->links;

print "Searching for images...\n";
my %images; # urls => names
tie %images , Tie::IxHash;
foreach $linkarray ( @links ) {
    my $ent = shift @$linkarray;
    my %attrs = @$linkarray;
#    print $ent , ( map { "\n\t$_ => $attrs{$_}" } keys %attrs ) , "\n";
    if ( $ent eq 'a' && $attrs{ 'href' } =~ m/(.+?(gif|jpg|jpeg))$/i ) {
	my $img_url = $1;
	$img_url =~ m/([^\/]+)$/;
	my $img_name = $1;
	$images{ $img_url } = $img_name;
    }
}

print "Fetching images...\n";
my $bar = Term::ProgressBar->new( scalar keys %images  );
my $x;
foreach my $img_url ( keys %images ) {
#	print "Fetching image $img_url\n";
    $req = HTTP::Request->new( GET => $img_url );
    $req->referer( $url );
    $response = $ua->request( $req );
    if ( $response->is_error( ) ) {
	warn "Could not fetch image " . $images{$img_url} . " ($img_url): " . $response->status_line . "\n";
	next;
    }
    my $img = $response->content( );
#        print "image name is $img_name\n";
    open IMAGE , ">$images{$img_url}" or die "Could not open $images{$img_url}: $!\n";
    print IMAGE $img;
    close IMAGE;
    $bar->update( $x++ );
}
$bar->update( scalar keys %images );

print "Generating index...\n";
$bar = Term::ProgressBar->new( scalar keys %images );
$x = 0;
open INDEX , ">index.html" or die "Could not open index.html: $!\n";
print INDEX "<html><body>\n";
foreach my $image ( values %images ) {
    $bar->update( $x++ );
    print INDEX '<p><img src="' . $image . '"></p>' . "\n";
}
$bar->update( scalar values %images );
print INDEX "</body></html>\n";
close INDEX;
print "All done.\n";
