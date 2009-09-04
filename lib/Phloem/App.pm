=head1 NAME

Phloem::App

=head1 DESCRIPTION

Phloem Content Delivery Network application.

=head1 SYNOPSIS

  C<use Phloem::App;>
  C<Phloem::App::run() or die "Failed to run Phloem.";>

=head1 METHODS

=over 8

=cut

package Phloem::App;

use strict;
use warnings;
use diagnostics;

use threads;

use lib qw(lib);
use Phloem::ComponentFactory;
use Phloem::ConfigLoader;
use Phloem::Logger;
use Phloem::NodeAdvertiser;
use Phloem::RegistryServer;

# This is the main --- indeed, the only --- version number for Phloem.
our $VERSION = 0.01;

#------------------------------------------------------------------------------

=item run

Run the application.

=cut

sub run
{
  # Initialise the logging subsystem, clear the log file, and write a
  # start-up message.
  Phloem::Logger->initialise();
  Phloem::Logger->clear();
  Phloem::Logger->append('Starting up.');

  # Load the configuration file.
  my $node = Phloem::ConfigLoader::load()
    or die "Failed to load configuration file.";

  # If this is the root node, then start the registry server running.
  if ($node->is_root()) {
    my $child_pid = Phloem::RegistryServer->run($node->root())
      or die "Failed to run registry server.";
    Phloem::Logger->append(
      "Registry server child process started as PID $child_pid.");
  }

  # Start up a node advertiser for the node.
  my $node_advertiser_thread = threads->create(\&_run_node_advertiser, $node);

  # For each subscribe role, start a component running.
  my @role_component_threads;
  {
    my @subscribe_roles = $node->subscribe_roles();
    foreach my $subscribe_role (@subscribe_roles) {
      my $role_component_thread =
        threads->create(\&_run_role_component, $node, $subscribe_role);
      push(@role_component_threads, $role_component_thread);
    }
  }

  # Wait for all threads to terminate.
  foreach my $role_component_thread (@role_component_threads) {
    $role_component_thread->join();
  }
  $node_advertiser_thread->join();

  exit(0);
}

#------------------------------------------------------------------------------
sub _run_node_advertiser
# Run a node advertiser for the specified node.
{
  my $node = shift or die "No node specified.";
  die "Expected a node object." unless $node->isa('Phloem::Node');

  my $node_advertiser = Phloem::NodeAdvertiser->new('node' => $node)
    or die "Failed to create node advertiser.";

  Phloem::Logger->append('Starting node advertiser.');

  return $node_advertiser->run();
}

#------------------------------------------------------------------------------
sub _run_role_component
# Run a component for the specified node and role.
{
  my $node = shift or die "No node specified.";
  die "Expected a node object." unless $node->isa('Phloem::Node');

  my $role = shift or die "No role specified.";
  die "Expected a role object." unless $role->isa('Phloem::Role');

  my $component = Phloem::ComponentFactory::create($node, $role)
    or die "Failed to create component.";

  Phloem::Logger->append('Starting role component.');

  return $component->run();
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
