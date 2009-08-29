=head1 NAME

Phloem::Node

=head1 SYNOPSIS

  C<use Phloem::Node;>

=head1 METHODS

=over 8

=item new

Constructor.

=item id

Get the id.

=item group

Get the group.

=item is_root

Get the value of the "is root" flag.

=item host

Get the host.

=item description

Get the description.

=item root

Get the root.

=item rsync

Get the rsync parameters and settings.

=item roles

Get an array of the roles.

=item add_role

Add the specified role.

=item is_publisher

Does the node fulfil any publisher roles?

=item is_portal

Is the node acting as a "portal" for the specified route?

=item publishes_on_route

Does the node fulfil a publisher role for the specified route?

If so, then the relevant publish role is returned. Otherwise, a false value
is returned.

=back

=head1 DESCRIPTION

A node in a Phloem network.

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

package Phloem::Node;

use strict;
use warnings;
use diagnostics;

use lib qw(lib);

use base qw(Xylem::Dumper);

use Phloem::Role;
use Phloem::Root;

#------------------------------------------------------------------------------
sub new
# Constructor.
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $self = {'id'          => undef,
              'group'       => '',
              'is_root'     => 0,
              'host'        => 'localhost',
              'description' => '',
              'root'        => undef,
              'rsync'       => undef,
              'roles'       => [],
              @_};
  return bless($self, $class);
}

#------------------------------------------------------------------------------
sub id
# Get the id.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->{'id'};
}

#------------------------------------------------------------------------------
sub group
# Get the group.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->{'group'};
}

#------------------------------------------------------------------------------
sub is_root
# Get the value of the "is root" flag.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->{'is_root'};
}

#------------------------------------------------------------------------------
sub host
# Get the host.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->{'host'};
}

#------------------------------------------------------------------------------
sub description
# Get the description.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->{'description'};
}

#------------------------------------------------------------------------------
sub root
# Get the root.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->{'root'};
}

#------------------------------------------------------------------------------
sub rsync
# Get the rsync parameters and settings.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->{'rsync'};
}

#------------------------------------------------------------------------------
sub roles
# Get an array of the roles.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return @{$self->{'roles'}};
}

#------------------------------------------------------------------------------
sub add_role
# Add the specified role.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $role = shift or die "No role specified.";
  die "Expected a role object." unless $role->isa('Phloem::Role');

  # Add the role.
  push(@{$self->{'roles'}}, $role);
}

#------------------------------------------------------------------------------
sub is_publisher
# Does the node fulfil any publisher roles?
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  my @roles = $self->roles();
  foreach my $current_role (@roles) {
    return 1 if $current_role->isa('Phloem::Role::Publish');
  }

  # If we get here, then we failed to find a suitable role.
  return 0;
}

#------------------------------------------------------------------------------
sub is_portal
# Is the node acting as a "portal" for the specified route?
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $route = shift or die "No route specified.";
  die "Expected an ordinary scalar." if ref($route);

  die "Unexpected route specified." unless ($route =~ /^(?:root|leaf)ward$/o);

  # Iterate over the roles.
  my $pub_dir;
  my $sub_dir;
  my @roles = $self->roles();
  foreach my $role (@roles) {
    next unless ($role->route() eq $route);
    my $dir = $role->directory();
    if ($role->isa('Phloem::Role::Publish')) {
      $pub_dir = $dir;
    } else {
      $sub_dir = $dir;
    }
  }

  return ($pub_dir && $sub_dir && ($pub_dir eq $sub_dir)) ? 1 : 0;
}

#------------------------------------------------------------------------------
sub publishes_on_route
# Does the node fulfil a publisher role for the specified route?
#
# If so, then the relevant publish role is returned. Otherwise, a false value
# is returned.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $route = shift or die "No route specified.";
  die "Expected an ordinary scalar." if ref($route);

  die "Unexpected route specified." unless ($route =~ /^(?:root|leaf)ward$/o);

  my @roles = $self->roles();
  foreach my $current_role (@roles) {
    return $current_role if ($current_role->isa('Phloem::Role::Publish') &&
                             $current_role->route() eq $route);
  }

  # If we get here, then we failed to find a suitable role.
  return;
}

1;
