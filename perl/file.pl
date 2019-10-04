#!/usr/bin/perl
use warnings;
use strict;
use Carp;

use File::Find;

sub HELP_MESSAGE {
    my $fh = shift;
    print $fh "3. Írjon programot, ami egy adott könyvtárban (rekurzívan) megkeresi a legnagyobb file-t. (use File::Find)";
}

my $dir = 'D:\userdata\rozsnyai';
my $max_size = 0;
my $max_file;

my $progress_time = time;
my $progress = 0;

find(\&wanted, $dir);

sub wanted {
    $progress++;
    if ($progress % 100 == 0 && $progress_time+1 < time) {
        $progress_time = time;
        print "-\r";
    }
    if (-f) {
        my $size = -s;
        if ($size > $max_size) {
            $max_size = $size;
            $max_file = $File::Find::name;
        }
    }
}

print "The biggest file in '$dir' is '$max_file' with size of '$max_size' bytes.";
