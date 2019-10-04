#! /usr/bin/perl -w

package Progress_Bar;

use lib "./util";

use strict;
use Carp;
use ClassUtils;


my $_default_chars =  ["-","/","|","\\"];

sub new($@)
{
  my ($type, @progress_chars) = @_;
  my $this = {
       "progress_chars" => (scalar(@progress_chars) > 0 ? \@progress_chars : $_default_chars),
       "current" => 0
  };
  
  return bless ($this, $type);
}

sub _get_current {
  return ClassUtils->instance_method_call_check(shift)->{'current'};
}
sub _set_current {
  my $this = ClassUtils->instance_method_call_check(shift);
  my ($value) = @_;
  $this->{'current'} = $value;
}
sub progress_chars {
  return ClassUtils->instance_method_call_check(shift)->{'progress_chars'};
}

sub progress
{
  my $this = ClassUtils->instance_method_call_check(shift);
  my @progress_chars = @{$this->progress_chars};
  
  $this->_set_current(0)
      if ($this->_get_current > $#progress_chars);
  my $to_display = $progress_chars[$this->_get_current];
  $this->_set_current($this->_get_current + 1);
  
  return "\r".$to_display;
}

return 1;
