#!/usr/bin/perl

package CellType;

use lib '../util';

use warnings;
use strict;
use Carp;
use ClassUtils;

sub new {
    my $type = shift;
    my $this = {
        "name"=>shift
    };
    
    return bless ($this, $type);
}
my $_IN = CellType->new("In");
my $_FRONTIER = CellType->new("Frontier");
my $_OUT = CellType->new("Out");

sub In { $_IN; }
sub Frontier { $_FRONTIER; }
sub Out { $_OUT; }

sub to_string {
    my $this = ClassUtils->instance_method_call_check(shift);
    return "CellType::".$this->{"name"};
}

1;
