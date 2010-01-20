=head1 NAME

Xylem::Class

=head1 DESCRIPTION

A base class for Xylem classes.

=head1 SYNOPSIS

  package MyClass0;
  use Some::Class;
  use Some::Other::Class;
  use Xylem::Class ('base'  => [qw(Some::Other::Class)],
                    'fields' => {'name'    => '$',
                                 'aliases' => '@',
                                 'data'    => '%',
                                 'object'  => 'Some::Class'});
  package main;

  package MySpace;

  use Xylem::Class 'fields' => [qw(width height depth)];

  package main;

  package MySpaceTime;

  use Xylem::Class 'fields' => 'duration', 'base' => 'MySpace';

  package main;

  package MyFish;

  use Xylem::Class fields => 'species weight colour';

  package main;

  my $thing = MyClass0->new('name' => 'toiletduck');
  my $dummy = Some::Class->new();
  $thing->object($dummy);

  my $space = MySpace->new();
  $space->height(100);
  my $spacetime = MySpaceTime->new('width'    => 10,
                                   'height'   => 20,
                                   'depth'    => 30,
                                   'duration' => 40);

=cut

package Xylem::Class;

use strict;
use warnings;
use diagnostics;

use Carp;

use Badger::Class
  'uber'   => 'Badger::Class',
  'hooks'  => 'fields';

#------------------------------------------------------------------------------
# Class metaprogramming hook.
sub fields
{
  my ($self, $value) = @_;
  if (ref($value)) {
    if (ref($value) eq 'ARRAY') {
      $value = join(' ', @$value);
    } elsif (ref($value) eq 'HASH') {
      $value = join(' ', keys(%$value));
    } else {
      croak "Expected an array or hash reference.";
    }
  }
  $self->base('Badger::Base');
  $self->mutators($value);
  $self->config($value);
  $self->init_method('configure');
}

1;

=head1 COPYRIGHT

Copyright (C) 2009-2010 Simon Dawson.

=head1 AUTHOR

Simon Dawson E<lt>spdawson@gmail.comE<gt>

=head1 LICENSE

This file is part of Xylem.

   Xylem is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Xylem is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Xylem.  If not, see <http://www.gnu.org/licenses/>.

=cut
