=head1 NAME

Phloem::App

=head1 SYNOPSIS

  C<use Phloem::App;>

=head1 METHODS

=over 8

=item run

Run the application.

=back

=head1 DESCRIPTION

Phloem Content Delivery Network application.

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

package Phloem::App;

use strict;
use warnings;
use diagnostics;

use lib qw(lib);
use Phloem::ComponentFactory;
use Phloem::ConfigLoader;
use Phloem::Logger;
use Phloem::NodeAdvertiser;
use Phloem::RegistryServer;

# This is the main --- indeed, the only --- version number for Phloem.
our $VERSION = 0.01;

#------------------------------------------------------------------------------
sub run
# Run the application.
{
  # Clear the log file, and write a start-up message.
  Phloem::Logger::clear();
  Phloem::Logger::append('Starting up.');

  # Load the configuration file.
  my $node = Phloem::ConfigLoader::load()
    or die "Failed to load configuration file.";

  # If this is the root node, then start the registry server running.
  if ($node->is_root()) {
    # Get the registry server port from the root node information.
    my $port = $node->root()->port();
    my $child_pid = Phloem::RegistryServer->run($port)
      or die "Failed to run registry server.";
    Phloem::Logger::append(
      "Registry server child process started as PID $child_pid.");
  } else {
    my $node_advertiser = Phloem::NodeAdvertiser->new('node' => $node)
      or die "Failed to create node advertiser.";
    my $child_pid = $node_advertiser->run()
      or die "Failed to run node advertiser.";
    Phloem::Logger::append(
      "Node advertiser child process started as PID $child_pid.");
  }

  # For each role, start a component running.
  my @roles = $node->roles();
  foreach my $role (@roles) {
    my $component = Phloem::ComponentFactory::create($node, $role)
      or die "Failed to create component.";
    my $child_pid = $component->run() or die "Failed to run component.";
    Phloem::Logger::append(
      "Component child process started as PID $child_pid.");
  }
}

1;
