#!/usr/bin/perl
package RomanNumber;

use warnings;
use strict;
use Carp;


my @_numbers = ();

sub new {
    my $type = shift;
    my $this = {
        "Value" => $_[0] ? $_[0] : 0,
        "Number_of_lines" => $_[1] ? $_[1] : 0,
        "String" => $_[2] ? $_[2] : ""
    };
    bless ($this, $type);
    
    push @_numbers, $this if defined $_[3];
    
    return $this;
}

sub get_number_of_lines {
    my $this = shift;
    unless (ref $this) {
        croak "The get_number_of_lines method has been called incorrectly! \n";
    }
    return $this->{"Number_of_lines"};
}

sub get_value {
    my $this = shift;
    unless (ref $this) {
        croak "The get_value method has been called incorrectly! \n";
    }
    return $this->{"Value"};
}

sub get_string {
    my $this = shift;
    unless (ref $this) {
        croak "The get_string method has been called incorrectly! \n";
    }
    return $this->{"String"};
}

sub to_string {
    my $this = shift;
    unless (ref $this) {
        croak "The to_string method has been called incorrectly! \n";
    }
    return "RomanNumber[".$this->get_value().",".$this->get_number_of_lines()."]";
}

sub concatenate {
    my $this = shift;
    unless (ref $this) {
        croak "The concatenate method has been called incorrectly! \n";
    }
    my $other_number = $_[0];
    
    my $result = RomanNumber->new(
        $other_number->get_value() <= $this->get_value() ?
            $other_number->get_value()+$this->get_value() :
            $other_number->get_value()-$this->get_value(),
        $this->get_number_of_lines()+$other_number->get_number_of_lines(),
        $this->get_string().$other_number->get_string()
    );
    
    push @_numbers, $result if defined $_[1];
    
    return $result;
}

sub equals {
    my $this = shift;
    unless (ref $this) {
        croak "The concatenate method has been called incorrectly! \n";
    }
    
    my $other_number = $_[0];
    return $this->get_value() == $other_number->get_value()
        && $this->get_number_of_lines() == $other_number->get_number_of_lines()
        && $this->get_string() == $other_number->get_string();
}

my $_I = RomanNumber->new(1,1,"I","true");
my $_V = RomanNumber->new(5,2,"V","true");
my $_IV = $_I->concatenate($_V,"true");
my $_X = RomanNumber->new(10,2,"X","true");
my $_IX = $_I->concatenate($_X,"true");
my $_L = RomanNumber->new(50,2,"L","true");
my $_XL = $_X->concatenate($_L,"true");
my $_C = RomanNumber->new(100,3,"C","true");
my $_XC = $_X->concatenate($_C,"true");
my $_D = RomanNumber->new(500,4,"D","true");
my $_CD = $_C->concatenate($_D,"true");
my $_M = RomanNumber->new(1000,4,"M","true");
my $_CM = $_C->concatenate($_M,"true");


sub I { $_I; }
sub IV { $_IV; }
sub V { $_V; }
sub IX { $_IX; }
sub X { $_X; }
sub XL { $_XL; }
sub L { $_L; }
sub XC { $_XC; }
sub C { $_C; }
sub CD { $_CD; }
sub D { $_D; }
sub CM { $_CM; }
sub M { $_M; }

my @_numbers_by_value_dec = sort {$b->get_value() <=> $a->get_value()} @_numbers;
my @_numbers_by_lines_dec = sort {$b->get_number_of_lines() <=> $a->get_number_of_lines()} @_numbers;

sub roman_numbers {
    my $this = shift;
    
    return @_numbers;
}

sub to_roman_number {
    my $this = shift;
    
    my $number = $_[0];
    my $result = RomanNumber->new();
    my $curr_divider = 0;
    my $divider = $_numbers_by_value_dec[$curr_divider];
    while ($number != 0) {
        if ($number >= $divider->get_value()) {
            $number -= $divider->get_value();
            $result = $result->concatenate($divider);
        }
        else {
            $divider = $_numbers_by_value_dec[++$curr_divider];
        }
    }
    return $result;
}

sub find {
    my $this = shift;
    
    my $val_min = $_[0];
    my $val_max = $_[1];
    
    my $curr = 0;
    my @steps = ();
    my $max = I;
    while ($curr <= $#_numbers_by_lines_dec) {
        my $num = $_numbers_by_lines_dec[$curr];
        if (
            $#steps == -1 ||
            $#steps >= 1 && $steps[$#steps-1]->equals($num) ||
            $#steps >= 0 && $steps[$#steps]->equals($num)
        ) {
            if ($#steps >= 2 && $steps[$#steps-2]->equals($num)) {
                $curr++;
            }
            else {
                push @steps, $num;
            }
        }
        my $val = 0;
        foreach (@steps) { $val += $_->get_value(); }
        if ($val > $val_max) {
            pop @steps;
            $curr++;
        }
    }
    
    my $result = RomanNumber->new();
    foreach (@steps) { $result = $result->concatenate($_); }
    return $result;
}


1;
