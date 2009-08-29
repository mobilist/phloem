=head1 NAME

Xylem::Utils::Net

=head1 SYNOPSIS

  C<use Xylem::Utils::Net;>

=head1 METHODS

=over 8

=item get_broadcast_send_socket

Get a socket with which to broadcast to the specified port.

=item get_broadcast_recv_socket

Get a socket with which to listen for broadcasts on the specified port.

=item ping

Ping the specified IP address.

Returns 1 if the ping was successful; 0 otherwise.

=back

=head1 DESCRIPTION

Network utilities for Xylem.

=head1 COPYRIGHT

Copyright (C) 2009 Simon Dawson.

=head1 AUTHOR

Simon Dawson E<lt>spdawson@gmail.comE<gt>

=head1 LICENSE

This file is part of Xylem.

   Xylem is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Xylem is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Xylem.  If not, see <http://www.gnu.org/licenses/>.

=cut

package Xylem::Utils::Net;

use strict;
use warnings;
use diagnostics;

use IO::Socket::INET;
use Net::Ping;

use lib qw(lib);

#------------------------------------------------------------------------------
sub get_broadcast_send_socket
# Get a socket with which to broadcast to the specified port.
{
  my $port = shift or die "No port specified.";

  my $sock = IO::Socket::INET->new('PeerAddr'  => inet_ntoa(INADDR_BROADCAST),
                                   'PeerPort'  => $port,
                                   'Proto'     => 'udp',
                                   'LocalAddr' => 'localhost',
                                   'Broadcast' => 1)
    or die "Failed to create send socket for broadcast: $@";

  return $sock;
}

#------------------------------------------------------------------------------
sub get_broadcast_recv_socket
# Get a socket with which to listen for broadcasts on the specified port.
{
  my $port = shift or die "No port specified.";

  my $sock = IO::Socket::INET->new('PeerAddr' => inet_ntoa(INADDR_ANY),
                                   'PeerPort' => $port,
                                   'Proto'    => 'udp')
    or die "Failed to create receive socket for broadcast: $@";

  return $sock;
}

#------------------------------------------------------------------------------
sub ping
# Ping the specified IP address.
#
# Returns true if the ping was successful; false otherwise.
{
  # Get the input: an IP address to ping.
  my $ip_address = shift or die "No IP address specified.";

  # Create a pinger.
  my $sonar = Net::Ping->new() or die "Failed to create pinger: $!";

  # Can we see the host?
  return $sonar->ping($ip_address);
}

1;
