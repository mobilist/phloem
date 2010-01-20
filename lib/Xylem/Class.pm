=head1 NAME

Xylem::Class

=head1 DESCRIPTION

A base class for Xylem classes.

=head1 SYNOPSIS

  package MyClass;
  use Some::Class;
  use Some::Other::Class;
  use Xylem::Class ('base'  => [qw(Some::Other::Class)],
                    'fields' => {'name'    => '$',
                                 'aliases' => '@',
                                 'data'    => '%',
                                 'object'  => 'Some::Class'});
  package main;

  my $thing = MyClass->new('name' => 'toiletduck');
  my $dummy = Some::Class->new(...);
  $thing->object($dummy);

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
  croak "Expected a hash reference." unless ref($value) eq 'HASH';
  my $field_names = join(' ', keys(%$value));
  $self->base('Badger::Base');
  $self->mutators($field_names);
  $self->config($field_names);
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
