=head1 NAME

Xylem::Dumper::Binary

=head1 DESCRIPTION

A base class for objects that are dumpable as binary data.

=head1 SYNOPSIS

  package MyClass;
  use base qw(Xylem::Dumper::Binary);
  sub new { bless({}, __PACKAGE__); };
  package main;
  use FileHandle;
  my $object = MyClass->new();
  my $fh = FileHandle->new('> myclass.dat');
  print $fh $object->data_dump();

=cut

package Xylem::Dumper::Binary;

use strict;
use warnings;
use diagnostics;

use Carp;
use Storable qw(nfreeze thaw);

use lib qw(lib);

use base qw(Xylem::Dumper);

#------------------------------------------------------------------------------
sub _do_data_dump
# Generate an object dump --- "protected" method.
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $data = nfreeze($self) or croak "Failed to freeze data: $!";
  return $data;
}

#------------------------------------------------------------------------------
sub _do_data_load
# Recreate an object from the specified dumped data --- "protected" method.
#
# N.B. This is a class method.
{
  my $class = shift or croak "No class name specified.";
  croak "Expected an ordinary scalar." if ref($class);
  croak "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $data = shift or croak "No object data specified.";

  my $self = thaw($data) or croak "Failed to thaw data.";
  return bless($self, $class);
}

1;

=head1 SEE ALSO

L<Xylem::Dumper>, L<Xylem::Dumper::Text>

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
