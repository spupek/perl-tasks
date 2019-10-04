#!/usr/bin/perl

package RandomUtils;

use warnings;
use strict;
use Carp;

use IllegalArgumentException;

sub random_item_from_array {
    my ($this,@array) = @_;
    
    if ($#array < 0) {
        croak IllegalArgumentException->new("Array is empty");
    }
    
    return $array[int(rand$#array+1)];
}

1;