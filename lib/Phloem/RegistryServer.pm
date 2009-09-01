=head1 NAME

Phloem::RegistryServer

=head1 DESCRIPTION

Registry server for Phloem.

=head1 SYNOPSIS

  C<use Phloem::RegistryServer;>

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

package Phloem::RegistryServer;

use strict;
use warnings;
use diagnostics;

use base 'Xylem::Server';

use lib qw(lib);
use Phloem::Constants;
use Phloem::Logger;
use Phloem::Registry;
use Xylem::Debug;

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

  Xylem::Debug::message('Client connected to server.');

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
      Xylem::Debug::message($input);
      alarm($timeout);
    }
    alarm($previous_alarm);

  };

  if ($@ =~ /Timed out\./o) {
    Xylem::Debug::message('Server timed out.');
    print $client_sock "ERROR: Timed out.\r\n";
    return;
  }

  # Load the registry.
  my $registry = Phloem::Registry->load();

  # See what we got.
  if ($is_get) {
    # The client wants details of the registry.
    Xylem::Debug::message('Client requested registry details.');
    print $client_sock $registry->data_dump(), "\r\n";
  } elsif ($input) {
    # The client is sending us details of a node.
    Xylem::Debug::message('Client sent node details.');
    eval {
      my $node = Phloem::Node->data_load($input)
        or die "Failed to recreate node object.";

      Xylem::Debug::message('Client sent node... ' . $node->data_dump());

      # Update the registry with the node information.
      $registry->add_node($node);

      # Save the updated registry.
      Xylem::Debug::message('Saving updated registry.');
      $registry->save();
    };
    if ($@) {
      print $client_sock "ERROR: Failed to process node data.\r\n";
    } else {
      print $client_sock "OK\r\n";
    }
  } else {
    print $client_sock "ERROR: No input.\r\n";
  }
}

1;
