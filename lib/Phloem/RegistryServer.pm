=head1 NAME

Phloem::RegistryServer

=head1 DESCRIPTION

Registry server for Phloem.

=head1 SYNOPSIS

  use Phloem::RegistryServer;

=head1 METHODS

=over 8

=cut

package Phloem::RegistryServer;

use strict;
use warnings;
use diagnostics;

use lib qw(lib);

use base qw(Xylem::Server);

use Phloem::Constants;
use Phloem::Debug;
use Phloem::Logger;
use Phloem::Registry;
use Phloem::Root;

#------------------------------------------------------------------------------

=item run

Run the server on the specified root.

A hash reference of options can optionally be specified, as the second
argument. This can include the 'HOST' (server host name/address) and 'DAEMON'
(flag --- seee below) entries.

By default, the server runs as a daemon: this method spawns a child process
and returns the PID. However, if the 'DAEMON' flag is explicitly set down,
then the server will be run in-process.

N.B. This is a class method.

=cut

sub run
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $root = shift or die "No root specified.";
  die "Expected a root object." unless $root->isa('Phloem::Root');

  my $args_hash = shift || {}; # Optional second argument.
  die "Expected a hash reference." unless (ref($args_hash) eq 'HASH');

  my $port = $root->port();

  $args_hash->{'HOST'} = $root->host();

  return $class->SUPER::run($port, $args_hash);
}

#------------------------------------------------------------------------------
sub process_request
# Process the request on the specified client socket --- "protected" method.
#
# N.B. This is a class method.
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $client_sock = shift or die "No client socket specified.";
  die "Expected a TCP/IP socket." unless $client_sock->isa('IO::Socket::INET');

  Phloem::Debug->message('Client connected to server.');

  my $is_get = 0;

  # Use time-outs to prevent denial-of-service attacks while reading.
  my $input = '';
  eval {

    local $SIG{'ALRM'} = sub { die "Timed out."; };
    my $timeout = $Phloem::Constants::REGISTRY_SERVER_TIMEOUT_S;

    my $previous_alarm = alarm($timeout);
    while (defined(my $current_line = $client_sock->getline())) {

      # Stop reading input as soon as we get an empty line.
      last if $current_line =~ /^\s*$/o;

      if ($current_line =~ /^\s*GET\s*$/o) {
        $is_get = 1;
        return; # (From the eval --- stop gathering input.)
      }
      $current_line =~ s/\r?\n$//o;
      $input .= $current_line;
      Phloem::Debug->message($input);
      alarm($timeout);
    }
    alarm($previous_alarm);

  };

  if ($@ =~ /Timed out\./o) {
    Phloem::Debug->message('Server timed out.');
    print $client_sock "ERROR: Timed out.\r\n";
    return;
  }

  # Load the registry.
  my $registry = Phloem::Registry->load();

  # See what we got.
  if ($is_get) {
    # The client wants details of the registry.
    Phloem::Debug->message('Client requested registry details.');
    print $client_sock $registry->data_dump(), "\r\n";
  } elsif ($input) {
    # The client is sending us details of a node.
    Phloem::Debug->message('Client sent node details.');
    eval {
      my $node = Phloem::Node->data_load($input)
        or die "Failed to recreate node object.";

      Phloem::Debug->message('Client sent node... ' . $node->data_dump());

      # Update the registry with the node information.
      $registry->add_node($node);

      # Save the updated registry.
      Phloem::Debug->message('Saving updated registry.');
      $registry->save();
    };
    if ($@) {
      print $client_sock "ERROR: Failed to process node data: $@\r\n";
    } else {
      print $client_sock "OK\r\n";
    }
  } else {
    print $client_sock "ERROR: No input.\r\n";
  }
}

1;

=back

=head1 SEE ALSO

L<Xylem::Server>

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
