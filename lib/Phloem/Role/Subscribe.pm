=head1 NAME

Phloem::Role::Subscribe

=head1 DESCRIPTION

A subscribe role for a node in a Phloem network.

=head1 SYNOPSIS

  use Phloem::Role::Subscribe;

=head1 METHODS

=over 8

=cut

package Phloem::Role::Subscribe;

use strict;
use warnings;
use diagnostics;

use lib qw(lib);
use Phloem::Filter;

use base qw(Phloem::Role);

#------------------------------------------------------------------------------

=item new

Constructor.

=cut

sub new
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  # Construct the base class part.
  my $self = $class->SUPER::new('filter'             => undef,
                                'update_frequency_s' => undef,
                                @_);

  # Re-bless into the subclass.
  return bless($self, $class);
}

#------------------------------------------------------------------------------

=item filter

Get the filter.

=cut

sub filter
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->{'filter'};
}

#------------------------------------------------------------------------------

=item update_frequency_s

Get the update frequency, in seconds.

=cut

sub update_frequency_s
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->{'update_frequency_s'};
}

1;

=back

=head1 SEE ALSO

L<Phloem::Role>, L<Phloem::Role::Publish>

=head1 COPYRIGHT

Copyright (C) 2009 Simon Dawson.

=head1 AUTHOR

Simon Dawson E<lt>spdawson@gmail.comE<gt>

=head1 LICENSE

This file is part of Phloem.

   Phloem is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Phloem is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Phloem.  If not, see <http://www.gnu.org/licenses/>.

=cut
