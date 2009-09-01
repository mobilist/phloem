=head1 NAME

Phloem::NodeAdvertiser

=head1 DESCRIPTION

An object to handle the registration of a node with the "root" node.

=head1 SYNOPSIS

  C<use Phloem::NodeAdvertiser;>

=head1 METHODS

=over 8

=item new

Constructor.

=item node

Get the node.

=cut

package Phloem::NodeAdvertiser;

use strict;
use warnings;
use diagnostics;

use Class::Struct 'Phloem::NodeAdvertiser' => {'node'  => 'Phloem::Node'};

use lib qw(lib);
use Phloem::Constants;
use Phloem::Logger;
use Phloem::RegistryClient;
use Xylem::Utils::Process;

#------------------------------------------------------------------------------

=item run

Run the advertiser.

Spawns a child process, and returns the PID.

=cut

sub run
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  # Spawn a new child process to run the component.
  my $child_pid = Xylem::Utils::Process::spawn_child('NODAEMON' => 1);
  return $child_pid if $child_pid;

  # (We're in the child process now.)

  # If the node is not a publisher, then we may as well shut down right now.
  unless ($self->node()->is_publisher()) {
    Phloem::Logger::append(
      'Node advertiser process shutting down: node does not publish.');
    exit(0);
  }

  # Sit in a loop, periodically registering our node with the "root" node.
  while (1) {
    Phloem::RegistryClient::register_node($self->node())
      or die "Failed to register node with root node.";
  } continue {
    sleep($Phloem::Constants::NODE_REGISTER_SLEEP_TIME_S);
  }
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
