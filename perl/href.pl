#!/usr/bin/perl
use warnings;
use strict;
use Carp;

use LWP::Simple;
use URI;

sub HELP_MESSAGE {
    my $fh = shift;
    print $fh "2. Írjon programot, ami letölt egy html-t és kiszedi belőle az <a> tagek href-jeit. A relatív linkekből csináljon abszolútot. (use LWP, URI, mást ne nagyon useoljon)";
}

my $url = URI->new("http://www.perlmonks.org/?node_id=745018");
my $content = get $url;

#my $file="../resources/html_content.txt";
#open (FILE, $file) or
#    die "Can't open $file: $!\n";
#select((select(FILE), $/ = undef)[0]);
#my $content = <FILE>;
#close (FILE);

if ($content =~ m/<body>((.|\n)*)<\/body>/ig) {
    $content = $1;
}

my @hrefs;
foreach my $line (split /\n/, $content) {
    if( $line =~ m/<a(\s+\w+="(.*?)")+(>(.*?)<\/a>|\s*\/>)/g ) {
        my $link = ($& =~ m/href="(.*?)"/g)[0];
        push @hrefs, $link;
    }
}

my $uri_prefixes = join "|", 'http','https','ftp','sftp';

foreach (@hrefs) {
    unless ($_ =~ m/^(($uri_prefixes):\/\/)/i) {
        $_ = $url->as_string().$_;
    }
}
print join "\n", @hrefs;

