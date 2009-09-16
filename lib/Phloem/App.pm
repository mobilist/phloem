=head1 NAME

Phloem::App

=head1 DESCRIPTION

Phloem Content Delivery Network application.

=head1 SYNOPSIS

  use Phloem::App;
  Phloem::App->run() or die "Failed to run Phloem.";

=head1 METHODS

=over 8

=cut

package Phloem::App;

use strict;
use warnings;
use diagnostics;

use threads;

use Carp;

use Phloem::ConfigLoader;
use Phloem::Debug;
use Phloem::Logger;
use Phloem::NodeAdvertiser;
use Phloem::RegistryServer;
use Phloem::Subscriber;
use Phloem::Version;

#------------------------------------------------------------------------------

=item run

Run the application.

N.B. This is a class method.

=cut

sub run
{
  my $class = shift or croak "No class name specified.";
  croak "Expected an ordinary scalar." if ref($class);
  croak "Incorrect class name." unless $class->isa(__PACKAGE__);

  # Any arguments are assumed to comprise a hash table of options.
  my %options = @_;

  # Enable/disable debug output, as appropriate.
  Phloem::Debug->enabled($options{'DEBUG'} // 0);

  # Initialise the logging subsystem, clear the log file, and write a
  # start-up message.
  my $phloem_version = $Phloem::Version::VERSION;
  Phloem::Logger->initialise();
  Phloem::Logger->clear();
  Phloem::Logger->append("Starting up, Phloem version $phloem_version.");

  # Load the configuration file.
  my $node = Phloem::ConfigLoader::load()
    or croak "Failed to load configuration file.";

  # Run a registry server for the node, if appropriate.
  if ($node->is_root()) {
    threads->create(\&_run_registry_server, $node)
      or croak "Failed to create registry server thread: $!";
  }

  # Start up a node advertiser for the node.
  threads->create(\&_run_node_advertiser, $node)
      or croak "Failed to create node advertiser thread: $!";

  # For each subscribe role, start a subscriber running.
  {
    my @subscribe_roles = $node->subscribe_roles();
    foreach my $subscribe_role (@subscribe_roles) {
      threads->create(\&_run_subscriber, $node, $subscribe_role)
        or croak "Failed to create subscriber thread: $!";
    }
  }

  # Wait for all threads to terminate.
  foreach my $current_thread (threads->list()) {
    $current_thread->join();
  }

  Phloem::Logger->append('Shutting down.');

  exit(0);
}

#------------------------------------------------------------------------------
sub _run_registry_server
# Run a registry server for the specified node.
{
  my $node = shift or croak "No node specified.";
  croak "Expected a node object." unless $node->isa('Phloem::Node');

  Phloem::Logger->append('Starting registry server.');

  Phloem::RegistryServer->run($node->root(), {'daemon' => 0});

  # The registry server thread detaches itself now.
  threads->detach();
}

#------------------------------------------------------------------------------
sub _run_node_advertiser
# Run a node advertiser for the specified node.
{
  my $node = shift or croak "No node specified.";
  croak "Expected a node object." unless $node->isa('Phloem::Node');

  my $node_advertiser = Phloem::NodeAdvertiser->new('node' => $node)
    or croak "Failed to create node advertiser.";

  Phloem::Logger->append('Starting node advertiser.');

  return $node_advertiser->run();
}

#------------------------------------------------------------------------------
sub _run_subscriber
# Run a subscriber for the specified node and role.
{
  my $node = shift or croak "No node specified.";
  croak "Expected a node object." unless $node->isa('Phloem::Node');

  my $role = shift or croak "No role specified.";
  croak "Expected a subscribe role object."
    unless $role->isa('Phloem::Role::Subscribe');

  my $subscriber = Phloem::Subscriber->new('node' => $node, 'role' => $role)
    or croak "Failed to create subscriber.";

  Phloem::Logger->append('Starting role subscriber.');

  return $subscriber->run();
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
