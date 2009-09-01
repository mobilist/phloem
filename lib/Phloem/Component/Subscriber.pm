=head1 NAME

Phloem::Component::Subscriber

=head1 DESCRIPTION

A subscriber Phloem component.

=head1 SYNOPSIS

  C<use Phloem::Component::Subscriber;>

=head1 SEE ALSO

L<Phloem::Component>, L<Phloem::Component::Publisher>

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

package Phloem::Component::Subscriber;

use strict;
use warnings;
use diagnostics;

use lib qw(lib);
use Phloem::ConfigLoader;
use Phloem::Constants;
use Phloem::Debug;
use Phloem::Logger;
use Phloem::Node;
use Phloem::RegistryClient;
use Xylem::Rsync::Transfer;
use Xylem::Utils::Net;

use base qw(Phloem::Component);

#------------------------------------------------------------------------------
sub _do_run
# Run the component --- "protected" method.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  # Sit in a loop, periodically updating our content from the "best"
  # available publisher node and role.
  while (1) {
    Phloem::Debug->message('Choosing best publisher node.');
    my ($best_publisher_node, $best_publisher_role) =
      $self->_choose_best_publisher() or next;
    $self->_update_from_publisher($best_publisher_node, $best_publisher_role);
  } continue {
    sleep($Phloem::Constants::SUBSCRIBER_UPDATE_SLEEP_TIME_S);
  }
}

#------------------------------------------------------------------------------
sub _choose_best_publisher
# Choose the "best" available publisher node from which to update our content.
#
# Returns the node, and the relevant publish role.
#
# Returns undefined if no publisher node was available.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  # Find suitable publisher nodes.
  my @publisher_nodes = $self->_find_publishers();

  # Choose the "best" publisher node.
  #
  # N.B. This initial implementation is very very stupid: we just return the
  #      first publisher whose host we successfully manage to ping.
  my $num_nodes = @{$publisher_nodes[0]};
  for (my $i = 0; $i < $num_nodes; $i++) {
    my $node_i = $publisher_nodes[0]->[$i];
    my $role_i = $publisher_nodes[1]->[$i];
    my $host_i = $node_i->host()
      or die "Unknown host name for node " . $node_i->id() . ".";
    Phloem::Debug->message("Pinging $host_i.");
    if (Xylem::Utils::Net::ping($host_i)) {
      return ($node_i, $role_i);
    }
  }

  # If we get here, then we didn't manage to ping anything.
  return;
}

#------------------------------------------------------------------------------
sub _find_publishers
# Find suitable publisher nodes.
#
# Returnds an array containing a pair of array references. The first contains
# the nodes, which the second contains the relevant publish roles.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $node = $self->node() or die "No node.";
  my $role = $self->role() or die "No role.";

  # Retrieve a list of all nodes from the "root" node.
  my $root = $node->root();
  Phloem::Debug->message('Getting details of all nodes.');
  my @all_nodes = Phloem::RegistryClient::get_all_nodes($root);

  my $route = $role->route();
  my $filter = $role->filter();

  # Filter the list down to the publishers of interest.
  Phloem::Debug->message('Filtering the list of nodes.');
  my @publisher_nodes = ([], []);
  foreach my $current_node (@all_nodes) {

    # We're only interested in publisher nodes.
    next unless $current_node->is_publisher();

    # We don't want to subscribe from our own node.
    next if ($current_node->id() eq $node->id());

    # We only want publishers that publish on the route that we subscribe to.
    my $route_publish_role = $current_node->publishes_on_route($route);
    next unless $route_publish_role;

    # Apply our filter to the node.
    next if ($filter && !$filter->apply($current_node));

    push(@{$publisher_nodes[0]}, $current_node);
    push(@{$publisher_nodes[1]}, $route_publish_role);
  }

  return @publisher_nodes;
}

#------------------------------------------------------------------------------
sub _update_from_publisher
# Update our content from the specified publisher node and role.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $node = shift or die "No node specified.";
  die "Expected a node object." unless $node->isa('Phloem::Node');

  my $role = shift or die "No role specified.";
  die "Expected a role object." unless $role->isa('Phloem::Role');

  Phloem::Debug->message('About to update from publisher node.');

  # Get some details required to specify the transfer.
  my $remote_ip_address = $node->host();
  my $remote_user = $node->rsync()->user();
  my $remote_path = $role->directory();
  my $local_path = $self->role()->directory();

  # Transfer data from the remote host.
  Xylem::Rsync::Transfer::go($remote_ip_address,
                             $remote_user,
                             $remote_path,
                             $local_path) or die "Failed to transfer data.";
}

1;
