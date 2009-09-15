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

require overload;

use Carp;
use Data::Dumper;
use Safe;
use Scalar::Util qw(blessed reftype refaddr);

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

  # Fix up any blessed references.
  _walk($self);

  return $self;
}

#------------------------------------------------------------------------------
sub _walk
# Walk the specified data structure, fixing up any blessed references.
#
# We need to do this because the values we get back from the Safe compartment
# will have packages defined from the compartment's *main instead of our own.
#
# N.B. This is heavily based on code from CGI::Session::Serialize::default,
#      but with the overload-handling code removed. (We don't care about
#      overloading: none of our code uses it.)
{
  my @filter = _scan(shift);

  # N.B. We allow the value assigned to a key to be undef; hence the defined()
  # test is not in the while().
  my %seen;
  while (@filter) {
    defined(my $x = shift(@filter)) or next;
    $seen{refaddr($x) || ''}++ and next;

    my $reftype = reftype($x) or next;
    if ($reftype eq 'HASH') {
      # We use this form to make certain we have aliases to the values in
      # %$x and not copies.
      push(@filter, _scan(@{$x}{keys(%$x)}));
    } elsif ($reftype eq 'ARRAY') {
      push(@filter, _scan(@$x));
    } elsif ($reftype eq 'SCALAR' || $reftype eq 'REF') {
      push(@filter, _scan($$x));
    } else {
      croak "Reference type $reftype is not supported.";
    }
  }
}

#------------------------------------------------------------------------------
sub _scan
# Scan the specified data structure, re-blessing as necessary.
{
  # N.B. $_ gets aliased to each value from @_ which are aliases of the
  #      values in the current data structure.
  for (@_) {
    next unless blessed($_);
    croak "Overloading is not supported." if overload::Overloaded($_);
    bless($_, ref($_));
  }
  return @_;
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
