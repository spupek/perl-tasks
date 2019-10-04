#!/usr/bin/perl
use warnings;
use strict;
use Carp;

use RomanNumber;

use Getopt::Std;
$Getopt::Std::STANDARD_HELP_VERSION = 1;

sub HELP_MESSAGE {
    my $fh = shift;
    print $fh "1. Írjon programot, ami megmondja, hogy 1..1000 között melyik római szám leírásához kell a legtöbb vonal. (Függőségmentes megoldás előnyben.)";
}

my $max = RomanNumber->I;
my $current;
foreach (1...1000) {
    $current = RomanNumber->to_roman_number($_);
    if ($max->get_number_of_lines() < $current->get_number_of_lines()) {
        $max = $current;
    }
}

print "Number with maximum lines between 1 and 1000 is: ".$max->get_string()."(".$max->to_string().")\n";

#my $max = RomanNumber->find(1,10000);
#print "Number with maximum lines between 1 and 1000 is: ".$max->get_string()."(".$max->to_string().")\n";
