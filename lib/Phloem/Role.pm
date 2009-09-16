=head1 NAME

Phloem::Role

=head1 DESCRIPTION

Base class for a role for a node in a Phloem network.

=head1 SYNOPSIS

  use Phloem::Role;
  my $role = Phloem::Role->new('route'       => 'leaf2root',
                               'directory'   => 'some/dir/path',
                               'description' => 'Some sort of role.');

  # Change the route.
  $role->route('leaf2root');

  print $role->description(), "\n";

=head1 METHODS

=over 8

=cut

package Phloem::Role;

use strict;
use warnings;
use diagnostics;

use Carp;

#------------------------------------------------------------------------------

=item new

Constructor.

=cut

sub new
{
  my $class = shift or croak "No class name specified.";
  croak "Expected an ordinary scalar." if ref($class);
  croak "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $self = {'route'       => undef,
              'directory'   => undef,
              'description' => undef,
              @_};
  return bless($self, $class);
}

#------------------------------------------------------------------------------

=item route

Get/set the route.

=cut

sub route
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $value = shift;

  $self->{'route'} = $value if defined($value);

  return $self->{'route'};
}

#------------------------------------------------------------------------------

=item directory

Get/set the directory.

=cut

sub directory
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $value = shift;

  $self->{'directory'} = $value if defined($value);

  return $self->{'directory'};
}

#------------------------------------------------------------------------------

=item description

Get/set the description.

=cut

sub description
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $value = shift;

  $self->{'description'} = $value if defined($value);

  return $self->{'description'};
}

1;

=back

=head1 SEE ALSO

L<Phloem::Role::Publish>, L<Phloem::Role::Subscribe>

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
