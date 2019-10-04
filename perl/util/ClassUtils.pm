#!/usr/bin/perl

package ClassUtils;

use warnings;
use strict;
use Carp;

sub instance_method_call_check {
    #my $this = shift;
    my $this = $_[1];
    unless (ref $this) {
        croak "The method has been called on class. Call this method on an instance!\n";
    }
    return $this;
}

1;
