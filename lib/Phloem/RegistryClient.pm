=head1 NAME

Phloem::RegistryClient

=head1 DESCRIPTION

Registry client for Phloem.

=head1 SYNOPSIS

  C<use base qwCDN::RegistryClient;>

=head1 METHODS

=over 8

=cut

package Phloem::RegistryClient;

use strict;
use warnings;
use diagnostics;

use IO::Socket::INET;

use lib qw(lib);
use Phloem::Constants;
use Phloem::Logger;
use Phloem::Node;
use Phloem::Root;

#------------------------------------------------------------------------------

=item register_node

Register the specified node.

=cut

sub register_node
{
  my $node = shift or die "No node specified.";
  die "Expected a node object." unless $node->isa('Phloem::Node');

  # Get a socket for communicating with the registry server.
  my $sock =_get_socket($node->root());

  Phloem::Logger::append('DEBUG: Attempting to register a node.');

  # Dump the node data off to the registry server.
  print $sock $node->data_dump(), "\r\n", "\r\n";

  # Read the output from the registry server.
  my $input = _read_from_server_socket($sock);

  die "Registry server error: $input" unless ($input =~ /^OK\s*$/o);
}

#------------------------------------------------------------------------------

=item get_all_nodes

Retrieve a list of all nodes.

The root node must be specified.

=cut

sub get_all_nodes
{
  my $root = shift or die "No root specified.";
  die "Expected a root object." unless $root->isa('Phloem::Root');

  # Get a socket for communicating with the registry server.
  my $sock =_get_socket($root);

  Phloem::Logger::append('DEBUG: Attempting to request registry data.');

  # Send the request off to the registry server.
  print $sock "GET\r\n";

  # Read the output from the registry server.
  my $input = _read_from_server_socket($sock);

  if ($input =~ /^ERROR: (.*)$/o) {
    die "Registry server error: $1";
  }

  unless ($input && length($input) && $input !~ /^\s*$/o) {
    warn "Registry server returned no data.";
    return;
  }

  Phloem::Logger::append('DEBUG: About to use data returned from server.');

  # The server is sending us details of the registry.
  my $registry = Phloem::Registry->data_load($input)
    or die "Failed to recreate registry object.";

  # Get a hash table of the nodes.
  my %nodes_hash = $registry->nodes();

  # The values are the node objects.
  return values(%nodes_hash);
}

#------------------------------------------------------------------------------
sub _get_socket
# Get a socket for communicating with the registry server.
#
# The root node must be specified.
{
  my $root = shift or die "No root specified.";
  die "Expected a root object." unless $root->isa('Phloem::Root');

  Phloem::Logger::append(
    "Creating socket on " . $root->host() . ":" . $root->port() . ".");
  my $sock = IO::Socket::INET->new('PeerAddr' => $root->host(),
                                   'PeerPort' => $root->port(),
                                   'Proto'    => 'tcp',
                                   'Type'     => SOCK_STREAM,
                                   'Blocking' => 1)
    or die "Failed to create socket: $@";

  return $sock;
}

#------------------------------------------------------------------------------
sub _read_from_server_socket
# Read data from the specified server socket.
{
  my $sock = shift or die "No socket specified.";
  die "Expected a TCP/IP socket." unless $sock->isa('IO::Socket::INET');

  # Read from the socket.
  my $input = '';
  while (<$sock>) {
    $_ =~ s/\r?\n$//o;
    $input .= $_;
  }

  # Trim parenthetical whitespace.
  $input =~ s/^\s*//o;
  $input =~ s/\s*$//o;

  return $input;
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
