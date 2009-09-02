#!/usr/bin/perl -w
#
#D Client test script.

use strict;
use warnings;
use diagnostics;

use IO::Socket::INET;

use lib qw(lib);
use Phloem::Registry;

{
  register_node();

  my @nodes = get_all_nodes();
  foreach my $node (@nodes) {
    print %$node, "\n";
  }
}

sub register_node
{
  # Get a socket for communicating with the registry server.
  my $sock = _get_socket();

  print STDERR "Attempting to register a node.\n";

  # Dump the node data off to the registry server.
  print $sock "bless({'id' => 'dog'}, 'Phloem::Node')", "\r\n", "\r\n";

  # Read the output from the registry server.
  print STDERR "About to read from server socket.\n";
  my $input = _read_from_server_socket($sock);

  print STDERR "Registry server returned: $input\n";

###  close($sock);
}

sub get_all_nodes
{
  # Get a socket for communicating with the registry server.
  my $sock = _get_socket();

  print STDERR "Attempting to request registry data.\n";

  # Send the request off to the registry server.
  print $sock "GET\r\n";
  print $sock "\r\n";

  # Read the output from the registry server.
  my $input = _read_from_server_socket($sock);

  if ($input =~ /^ERROR: (.*)$/o) {
    die "Registry server error: $1";
  }

  unless ($input && length($input) && $input !~ /^\s*$/o) {
    print STDERR "Registry server returned no data.\n";
    return;
  }

###  close($sock);

  print STDERR "About to use data returned from server.\n";

  # The server is sending us details of the registry.
  my $registry = Phloem::Registry->data_load($input)
    or die "Failed to recreate registry object.";

  # Get a hash table of the nodes.
  my %nodes_hash = $registry->nodes();

  # The values are the node objects.
  return values(%nodes_hash);
}

sub _get_socket
{
  my $HOST = '10.127.10.4';
  my $PORT = '9999';
  print STDERR "Creating socket on " . $HOST . ":" . $PORT . ".\n";

  my $sock = Xylem::Utils::Net::get_client_tcp_socket($HOST, $PORT)
    or die "Failed to create client socket.";

  $sock->autoflush(1);

  return $sock;
}

sub _read_from_server_socket
{
  my $sock = shift or die "No socket specified.";
  die "Expected a TCP/IP socket." unless $sock->isa('IO::Socket::INET');

  # Read from the socket.
  print STDERR "Reading from server socket.\n";
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
