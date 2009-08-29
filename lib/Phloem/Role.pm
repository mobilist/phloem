=head1 NAME

Phloem::Role

=head1 SYNOPSIS

  C<use Phloem::Role;>

=head1 METHODS

=over 8

=item new

Constructor.

=item route

Get the route.

=item directory

Get the directory.

=item description

Get the description.

=back

=head1 DESCRIPTION

Base class for a role for a node in a Phloem network.

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

package Phloem::Role;

use strict;
use warnings;
use diagnostics;

use lib qw(lib);

#------------------------------------------------------------------------------
sub new
# Constructor.
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $self = {'route'       => undef,
              'directory'   => undef,
              'description' => '',
              @_};
  return bless($self, $class);
}

#------------------------------------------------------------------------------
sub route
# Get the route.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->{'route'};
}

#------------------------------------------------------------------------------
sub directory
# Get the directory.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->{'directory'};
}

#------------------------------------------------------------------------------
sub description
# Get the description.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->{'description'};
}

1;
