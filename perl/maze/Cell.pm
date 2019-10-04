#!/usr/bin/perl

package Cell;

use lib '../util';

use warnings;
use strict;
use Carp;
use ClassUtils;


sub new {
    my $type = shift;
    my $this = {
        "posx"=>shift,
        "posy"=>shift,
        "type"=>shift,
        "bottom"=>1,
        "right"=>1,
        "start"=>0,
        "end"=>0
    };
    return bless ($this, $type);
}

sub posx {
    return ClassUtils->instance_method_call_check(shift)->{'posx'};
}

sub posy {
    return ClassUtils->instance_method_call_check(shift)->{'posy'};
}

sub type {
    return ClassUtils->instance_method_call_check(shift)->{'type'};
}

sub start {
    return ClassUtils->instance_method_call_check(shift)->{'start'};
}

sub end {
    return ClassUtils->instance_method_call_check(shift)->{'end'};
}

sub mark_as_start {
    my $this =  ClassUtils->instance_method_call_check(shift);
    $this->{'start'} = 1;
}
sub mark_as_end {
    my $this =  ClassUtils->instance_method_call_check(shift);
    $this->{'end'} = 1;
}
sub mark_as_out {
    my $this = ClassUtils->instance_method_call_check(shift);
    $this->{'type'} = CellType->Out;
}
sub mark_as_in {
    my $this = ClassUtils->instance_method_call_check(shift);
    $this->{'type'} = CellType->In;
}
sub mark_as_frontier {
    my $this = ClassUtils->instance_method_call_check(shift);
    $this->{'type'} = CellType->Frontier;
}

sub carve_to {
    my $this = ClassUtils->instance_method_call_check(shift);
    my $other = shift;
    
    if ($other->posx == $this->posx) {
        if ($this->posy == $other->posy+1) {
            $other->set_bottom(0);
        }
        elsif ($this->posy == $other->posy-1) {
            $this->set_bottom(0);
        }
    }
    elsif ($other->posy == $this->posy) {
        if ($this->posx == $other->posx+1) {
            $other->set_right(0);
        }
        elsif ($this->posx == $other->posx-1) {
            $this->set_right(0);
        }
    }
}

sub get_bottom {
    return ClassUtils->instance_method_call_check(shift)->{'bottom'};
}
sub set_bottom {
    my $this = ClassUtils->instance_method_call_check(shift);
    my $value = shift;
    $this->{'bottom'} = $value;
}

sub get_right {
    return ClassUtils->instance_method_call_check(shift)->{'right'};
}
sub set_right {
    my $this = ClassUtils->instance_method_call_check(shift);
    my $value = shift;
    $this->{'right'} = $value;
}

sub to_string {
    my $this = ClassUtils->instance_method_call_check(shift);
    return "Cell(".$this->posx.",".$this->posy.",".$this->type->to_string.")";
}

1;
