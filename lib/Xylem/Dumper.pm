=head1 NAME

Xylem::Dumper

=head1 DESCRIPTION

A base class for dumpable objects.

=head1 SYNOPSIS

  C<package MyClass;>
  C<use base qw(Xylem::Dumper);>
  C<sub new { bless({}, __PACKAGE__); };>
  C<package main;>
  C<my $object = MyClass->new();>
  C<print $object->data_dump();>

=head1 METHODS

=over 8

=cut

package Xylem::Dumper;

use strict;
use warnings;
use diagnostics;

use Data::Dumper;
use Safe;

#------------------------------------------------------------------------------

=item data_dump

Generate a textual dump of the object data.

=cut

sub data_dump
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $dumper = Data::Dumper->new([$self], [qw(self)]);

  $dumper->Indent(0)->Purity(1)->Terse(1)->Deepcopy(1)->Sortkeys(1);

  return $dumper->Dump();
}

#------------------------------------------------------------------------------

=item data_load

Attempt to recreate an object from the specified textual data.

N.B. This is a class method.

=cut

sub data_load
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $data = shift or die "No textual data specified.";

  # Evaluate the code in an opcode-safe compartment. Only the base-minimum of
  # opcodes are allowed. In particular, no system calls can be made. This is
  # necessary because the data could have come from anywhere, and cannot
  # necessarily be trusted.
  my $self;
  my $compartment = Safe->new();
  $compartment->share('$self');
  # N.B. You might think that the next line would be necessary. Indeed, for
  #      some classes it may be. But not for ours.
#  $compartment->share_from($class, [qw(new)]);
  $compartment->permit_only(qw(:base_core bless padany anonhash));
  my $STRICT = 1;
  $self = $compartment->reval($data, $STRICT);
  die "Failed to reconstruct object: $@" if $@;
  die "Failed to reconstruct object of class $class."
    unless (ref($self) eq $class);

  # Okay, now we know that the code is safe. Let's eval it for real now.
  #
  # N.B. I have no idea why this is necessary --- it is likely to be a
  #      namespace problem. The first reval should be sufficient...
  $self = eval " $data ";
  die "Failed to eval object data: $@" if $@;

  return $self;
}

1;

=back

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
