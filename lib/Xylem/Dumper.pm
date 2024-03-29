=head1 NAME

Xylem::Dumper

=head1 DESCRIPTION

An abstract base class for objects that are, in some sense, dumpable.

=head1 SYNOPSIS

  package MyClass;
  use base qw(Xylem::Dumper);
  sub new { bless({}, __PACKAGE__); };
  package main;
  my $object = MyClass->new();
  print $object->data_dump();

=head1 METHODS

=over 8

=cut

package Xylem::Dumper;

use strict;
use warnings;
use diagnostics;

use Carp;

#------------------------------------------------------------------------------

=item data_dump

Generate a dump (textual or binary) of the object data.

=cut

sub data_dump
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->_do_data_dump();
}

#------------------------------------------------------------------------------

=item data_load

Attempt to recreate an object from the specified data, which may be textual or
binary.

N.B. This is a class method.

=cut

sub data_load
{
  my $class = shift or croak "No class name specified.";
  croak "Expected an ordinary scalar." if ref($class);
  croak "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $data = shift or croak "No object data specified.";

  return $class->_do_data_load($data);
}

#------------------------------------------------------------------------------
sub _do_data_dump
# Generate an object dump --- "protected" method.
#
# Subclasses must provide an implementation for this pure virtual method.
{
  croak "PURE VIRTUAL BASE CLASS METHOD! MUST BE OVERRIDDEN!";
}

#------------------------------------------------------------------------------
sub _do_data_load
# Recreate an object from the specified dumped data --- "protected" method.
#
# Subclasses must provide an implementation for this pure virtual method.
#
# N.B. This is a class method.
{
  croak "PURE VIRTUAL BASE CLASS METHOD! MUST BE OVERRIDDEN!";
}

1;

=back

=head1 SEE ALSO

L<Xylem::Dumper::Binary>, L<Xylem::Dumper::Text>

=head1 COPYRIGHT

Copyright (C) 2009 Simon Dawson.

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
