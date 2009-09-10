=head1 NAME

Xylem::Dumper::Text

=head1 DESCRIPTION

A base class for objects that are dumpable as textual data.

=head1 SYNOPSIS

  package MyClass;
  use base qw(Xylem::Dumper::Text);
  sub new { bless({}, __PACKAGE__); };
  package main;
  my $object = MyClass->new();
  print $object->data_dump();

=cut

package Xylem::Dumper::Text;

use strict;
use warnings;
use diagnostics;

use Carp;
use Data::Dumper;
use Safe;

use base qw(Xylem::Dumper);

#------------------------------------------------------------------------------
sub _do_data_dump
# Generate an object dump --- "protected" method.
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $dumper = Data::Dumper->new([$self], [qw(self)]);

  $dumper->Indent(0)->Purity(1)->Terse(1)->Deepcopy(1)->Sortkeys(1);

  return $dumper->Dump();
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

  # Check the object data for safety.
  $class->_check_object_code($data);

  # Okay, now we know that the code is safe. Let's eval it "for real".
  #
  # N.B. I have no idea why this is necessary --- it is likely to be a
  #      namespace problem. The first reval should be sufficient...
  #
  #      At http://www.perlmonks.org/?node_id=151604, I found the following
  #      note.
  #
  #        "Safe's restricted environment causes blessed objects to lose their
  #        'magic' when passed back out. Here we simply re-bless the object to
  #        correct that."
  #
  # However, re-blessing doesn't seem to quite do enough. (I submitted the
  # re-blessing code in revision 145, but have since reverted to the eval.)
  my $self = eval " $data ";
  croak "Failed to eval object data: $@" if $@;

  return $self;
}

#------------------------------------------------------------------------------
sub _check_object_code
# Check the specified textual data --- ostensibly, object code --- for safety.
#
# N.B. This is a class method.
{
  my $class = shift or croak "No class name specified.";
  croak "Expected an ordinary scalar." if ref($class);
  croak "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $data = shift or croak "No textual data specified.";

  # Evaluate the code in an opcode-safe compartment. Only the base-minimum of
  # opcodes are allowed. In particular, no system calls can be made. This is
  # necessary because the data could have come from anywhere, and cannot
  # necessarily be trusted.
  my $compartment = Safe->new();
  # N.B. You might think that the next line would be necessary. Indeed, for
  #      some classes it may be. But not for ours.
#  $compartment->share_from($class, [qw(new)]);
  $compartment->permit_only(qw(:base_core bless padany anonhash anonlist));
  my $STRICT = 1;
  my $self = $compartment->reval($data, $STRICT) or
    croak "Failed to reconstruct object: $@";
  croak "Failed to reconstruct object of class $class."
    unless (ref($self) eq $class);
}

1;

=head1 SEE ALSO

L<Xylem::Dumper>, L<Xylem::Dumper::Binary>

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