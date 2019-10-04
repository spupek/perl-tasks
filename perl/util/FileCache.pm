#! /usr/bin/perl -w
# $Id: 

package Util::FileCache;


use strict;
use warnings;

use ClassUtils;

use YAML;


my $package = __PACKAGE__;

sub new()
{
  my ($class, $file_name) = @_;
  
  my $this = {
    'cache' => {},
  };
  
  my $self = bless($this);
  
  $self->file_name($file_name);
  $self->loaded('');
  
  return $self;
}

sub file_name()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  my ($value) = @_;
  
  $self->{'file_name'} = $value
    if defined($value);
  
  return $self->{'file_name'};
}

sub valid_for()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  my ($value) = @_;
  
  $self->{'valid_for'} = $value
    if defined($value);
  
  return $self->{'valid_for'};
}

sub valid_for_after_accessed()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  my ($value) = @_;
  
  $self->{'valid_for_after_accessed'} = $value
    if defined($value);
  
  return $self->{'valid_for_after_accessed'};
}

sub _valid()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  my ($cache_item, $now) = @_;
  
  $now = time
    unless defined($now);
  my $item_time = $self->valid_for_after_accessed ? $cache_item->last_accessed
    : $cache_item->created;
  my $timeout = $cache_item->timeout ? $cache_item->timeout
    : $self->valid_for_after_accessed ? $self->valid_for_after_accessed
    : $self->valid_for;
  
  return !defined($timeout) || $timeout == 0 || $now - $item_time < $timeout;
}

sub cache()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  
  return $self->{'cache'};
}

sub loaded()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  my ($value) = @_;
  
  $self->{'loaded'} = $value
    if defined($value);
  
  return $self->{'loaded'};
}

sub load()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  
  $self->{'cache'} = undef;
  if (open FILE, "<".$self->file_name)
  {
    local $/;
    my $content = <FILE>;
    close FILE
      or warn "Could not close file: ".$self->file_name;
    if ($content)
    {
      my $loaded = Load($content);
      $self->{'cache'} = $loaded;
    }
  }
  else
  {
    warn "Could not open file to load from: ".$self->file_name;
  }
  
  $self->{'cache'} = {}
    unless (ref ($self->cache) eq "HASH");
  
  $self->loaded(1);
}

sub save()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  
  $self->_delete_invalids();
  
  my $content = Dump( $self->cache );
  if (open FILE, ">".$self->file_name)
  {
    print FILE $content;
    close FILE
     or warn "Could not close file: ".$self->file_name;
  }
  else
  {
    warn "Could not open file to store cache: ".$self->file_name;
  }
}

sub get()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  my ($key) = @_;
  
  $self->load
    unless ($self->loaded);
  
  return $self->_get_value($key)
    if ($self->has($key));
  
  return undef;
}

sub _get_value()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  my ($key) = @_;
  
  return $self->cache->{$key}->value;
}

sub set()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  my ($key, $value) = @_;
  
  $self->load
    unless ($self->loaded);
  
  my $cache_item = CacheItem->new( $value );
  return $self->cache->{$key} = $cache_item;
}

sub has()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  my ($key) = @_;
  
  $self->load
    unless ($self->loaded);
  
  return exists $self->cache->{$key} && $self->_valid($self->cache->{$key});
}

sub del()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  my ($key) = @_;
  $self->load
    unless ($self->loaded);
  
  delete $self->cache->{$key};
}

sub fetch()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  my ($key, $value) = @_;
  
  $self->load
    unless ($self->loaded);
  
  return $self->_get_value($key)
    if ($self->has($key));
  
  my $result = $value;
  $self->set($key, $result);
  
  return $result;
}

sub _delete_invalids()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  
  my $now = time;
  foreach my $key ( keys %{$self->cache})
  {
    my $item = $self->cache->{$key};
    $self->del($key)
      unless $self->_valid($item, $now);
  }
  
}

sub DESTROY {
  my $self = shift;
  
  $self->save();
}



package CacheItem;

use strict;
use warnings;

use ClassUtils;
use Time::HiRes qw ( time );

sub new()
{
  my ($class, $value, $timeout) = @_;
  
  my $now = time;
  my $this = {
    'value' => $value,
    'last_accessed' => $now,
    'created' => $now,
    'timeout' => $timeout,
  };
  
  return bless($this);
}

sub value()
{
  my $self = ClassUtils->instance_method_call_check(shift);
  my ($value) = @_;
  
  my $now = time;
  if (defined($value))
  {
    $self->{'value'} = $value;
    $self->{'created'} = $now
  }
  
  $self->{'last_accessed'} = $now;
  return $self->{'value'};
}

sub last_accessed()
{
  my $self = ClassUtils->instance_method_call_check(shift)->{'last_accessed'};
}

sub created()
{
  my $self = ClassUtils->instance_method_call_check(shift)->{'created'};
}

sub timeout()
{
  my $self = ClassUtils->instance_method_call_check(shift)->{'timeout'};
}

return 1;
