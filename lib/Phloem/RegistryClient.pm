=head1 NAME

Phloem::RegistryClient

=head1 SYNOPSIS

  C<use base qwCDN::RegistryClient;>

=head1 METHODS

=over 8

=item register_node

Register the specified node.

=item get_all_nodes

Retrieve a list of all nodes.

The root node must be specified.

=back

=head1 DESCRIPTION

Registry client for Phloem.

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
sub register_node
# Register the specified node.
{
  my $node = shift or die "No node specified.";
  die "Expected a node object." unless $node->isa('Phloem::Node');

  # We don't need to register the root node itself; that would be pointless.
  return if $node->is_root();

  # Get a socket for communicating with the registry server.
  my $sock =_get_socket($node->root());

  Phloem::Logger::append('DEBUG: Attempting to register a node.');

  # Dump the node data off to the registry server.
  print $sock $node->data_dump(), "\r\n";
}

#------------------------------------------------------------------------------
sub get_all_nodes
# Retrieve a list of all nodes.
#
# The root node must be specified.
{
  my $root = shift or die "No root specified.";
  die "Expected a root object." unless $root->isa('Phloem::Root');

  # Get a socket for communicating with the registry server.
  my $sock =_get_socket($root);

  Phloem::Logger::append('DEBUG: Attempting to request registry data.');

  # Send the request off to the registry server.
  print $sock "GET\r\n";

  # Read the output from the registry server.
  my $input = '';
  while (<$sock>) {
    $_ =~ s/\r?\n$//o;
    $input .= $_;
  }

  if ($input =~ /^ERROR: (.*)$/o) {
    die "Registry server error: $1";
  }

  die "Registry server returned no data."
    unless ($input && length($input) && $input !~ /^\s*$/o);

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

  my $sock = IO::Socket::INET->new('PeerAddr' => $root->host(),
                                   'PeerPort' => $root->port(),
                                   'Proto'    => 'tcp',
                                   'Type'     => SOCK_STREAM)
    or die "Failed to create socket: $@";

  return $sock;
}

1;
