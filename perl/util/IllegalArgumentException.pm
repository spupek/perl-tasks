#!/usr/bin/perl

package IllegalArgumentException;

use warnings;
use strict;
use Carp;

sub new {
    my $type = shift;
    my $this = {
        "message" => shift
    };
    return bless ($this, $type);
}

1;
