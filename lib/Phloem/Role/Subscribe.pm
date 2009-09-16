=head1 NAME

Phloem::Role::Subscribe

=head1 DESCRIPTION

A subscribe role for a node in a Phloem network.

=head1 SYNOPSIS

  use Phloem::Role::Subscribe;
  my $filter = Phloem::Filter->new('type'  => 'group',
                                   'value' => '^ova\d+',
                                   'rule'  => 'match');
  my $role =
    Phloem::Role::Subscribe->new('route'       => 'leaf2root',
                                 'directory'   => 'some/dir/path',
                                 'description' => 'Some sort of role.',
                                 'filter'      => $filter);

  # Set the update frequency, in seconds.
  $role->update_frequency_s(60);

=head1 METHODS

=over 8

=cut

package Phloem::Role::Subscribe;

use strict;
use warnings;
use diagnostics;

use Carp;

use Phloem::Filter;

use base qw(Phloem::Role);

#------------------------------------------------------------------------------

=item new

Constructor.

=cut

sub new
{
  my $class = shift or croak "No class name specified.";
  croak "Expected an ordinary scalar." if ref($class);
  croak "Incorrect class name." unless $class->isa(__PACKAGE__);

  # Construct the base class part.
  my $self = $class->SUPER::new('filter'             => undef,
                                'update_frequency_s' => undef,
                                @_);

  # Re-bless into the subclass.
  return bless($self, $class);
}

#------------------------------------------------------------------------------

=item filter

Get/set the filter.

=cut

sub filter
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $value = shift;

  $self->{'filter'} = $value if defined($value);

  return $self->{'filter'};
}

#------------------------------------------------------------------------------

=item update_frequency_s

Get/set the update frequency, in seconds.

=cut

sub update_frequency_s
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $value = shift;

  $self->{'update_frequency_s'} = $value if defined($value);

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
