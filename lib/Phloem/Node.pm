=head1 NAME

Phloem::Node

=head1 DESCRIPTION

A node in a Phloem network.

=head1 SYNOPSIS

  use Phloem::Node;

  my $node = Phloem::Node->new('id' => 'horse53', 'is_root' => 1);

  my $node_id = $node->id();
  $node->group('test');
  die "Expected a root node." unless $node->is_root();
  print "Host: ", $node->host(), "\n";
  $node->register_frequency_s(30);
  print "Description: ", $node->description(), "\n";
  my $root = $node->root();
  my $rsync = $node->rsync();
  my $roles_arrayref = $node->roles();

  my $role = Phloem::Role::Publish->new('route'     => 'root2leaf',
                                        'directory' => 'some/dir/path');
  $node->add_role($role);

  die "Expected node to publish." unless $node->is_publisher();
  die "Expected node to publish on the 'root2leaf' route."
    unless $node->publishes_on_route('root2leaf');

  my @subscribe_roles = $node->subscribe_roles();
  die "Did not expect the node to subscribe." if @subscribe_roles;
  die "Expected a non-portal node on the 'root2leaf' route."
    if $node->is_portal('root2leaf');

=head1 METHODS

=over 8

=item new

Constructor.

=item id

Get/set the id.

=item group

Get/set the group.

=item is_root

Get/set the value of the "is root" flag.

=item host

Get/set the host.

=item register_frequency_s

Get/set the register frequency, in seconds.

=item description

Get/set the description.

=item root

Get/set the root.

=item rsync

Get/set the rsync parameters and settings.

=item roles

Get an array reference of the roles.

=cut

package Phloem::Node;

use strict;
use warnings;
use diagnostics;

use Carp;

use Phloem::Dumper;
use Phloem::Role;
use Phloem::Root;

use Xylem::Class ('class'  => 'Phloem::Node',
                  'bases'  => [qw(Phloem::Dumper)],
                  'fields' => {'id'                   => '$',
                               'group'                => '$',
                               'is_root'              => '$',
                               'host'                 => '$',
                               'register_frequency_s' => '$',
                               'description'          => '$',
                               'root'                 => 'Phloem::Root',
                               'rsync'                => 'Phloem::Rsync',
                               'roles'                => '@'});

#------------------------------------------------------------------------------

=item add_role

Add the specified role.

=cut

sub add_role
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $role = shift or croak "No role specified.";
  croak "Expected a role object." unless $role->isa('Phloem::Role');

  # Add the role.
  push(@{$self->{'roles'}}, $role);
}

#------------------------------------------------------------------------------

=item subscribe_roles

Get an array of the subscriber roles.

=cut

sub subscribe_roles
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  my @subscribe_roles;
  {
    my $roles_arrayref = $self->roles();
    foreach my $current_role (@$roles_arrayref) {
      push(@subscribe_roles, $current_role)
        if $current_role->isa('Phloem::Role::Subscribe');
    }
  }

  return @subscribe_roles;
}

#------------------------------------------------------------------------------

=item is_publisher

Does the node fulfil any publisher roles?

=cut

sub is_publisher
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $roles_arrayref = $self->roles();
  foreach my $current_role (@$roles_arrayref) {
    return 1 if $current_role->isa('Phloem::Role::Publish');
  }

  # If we get here, then we failed to find a suitable role.
  return 0;
}

#------------------------------------------------------------------------------

=item is_portal

Is the node acting as a "portal" for the specified route?

=cut

sub is_portal
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $route = shift or croak "No route specified.";
  croak "Expected an ordinary scalar." if ref($route);

  croak "Unexpected route specified."
    unless ($route =~ /^(?:root2leaf|leaf2root)$/o);

  # Iterate over the roles.
  my $pub_dir;
  my $sub_dir;
  my $roles_arrayref = $self->roles();
  foreach my $role (@$roles_arrayref) {
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

=item publishes_on_route

Does the node fulfil a publisher role for the specified route?

If so, then the relevant publish role is returned. Otherwise, a false value
is returned.

=cut

sub publishes_on_route
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $route = shift or croak "No route specified.";
  croak "Expected an ordinary scalar." if ref($route);

  croak "Unexpected route specified."
    unless ($route =~ /^(?:root2leaf|leaf2root)$/o);

  my $roles_arrayref = $self->roles();
  foreach my $current_role (@$roles_arrayref) {
    return $current_role if ($current_role->isa('Phloem::Role::Publish') &&
                             $current_role->route() eq $route);
  }

  # If we get here, then we failed to find a suitable role.
  return;
}

1;

=back

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
