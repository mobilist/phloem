=head1 NAME

Xylem::Utils::Net

=head1 DESCRIPTION

Network utilities for Xylem.

=head1 SYNOPSIS

  use Xylem::Utils::Net;

  print "We can do searching.\n" if Xylem::Utils::Net::ping('google.com');

  my $server_sock = Xylem::Utils::Net::get_server_tcp_socket(9999, '1.2.3.4');

  my $client_sock = Xylem::Utils::Net::get_client_tcp_socket('1.2.3.4', 9999);

  my $data = Xylem::Utils::Net::read_from_socket($client_sock);

=head1 METHODS

=over 8

=cut

package Xylem::Utils::Net;

use strict;
use warnings;
use diagnostics;

use Carp;
use IO::Socket::INET;
use Net::Ping;

use constant XYLEM_SOCK_TIMEOUT_S => 31536000; # One calendar year.

#------------------------------------------------------------------------------

=item ping

Ping the specified IP address.

Returns 1 if the ping was successful; 0 otherwise.

=cut

sub ping
{
  # Get the input: an IP address to ping.
  my $ip_address = shift or croak "No IP address specified.";

  # Create a pinger.
  my $sonar = Net::Ping->new() or croak "Failed to create pinger: $!";

  # Can we see the host?
  return $sonar->ping($ip_address);
}

#------------------------------------------------------------------------------

=item get_server_tcp_socket

Get a client TCP socket for running a server on the specified port.

A host can optionally be specified, as the second argument.

=cut

sub get_server_tcp_socket
{
  my $port = shift or croak "No port specified.";
  my $host = shift; # Optional second argument.

  my %sock_options = ('LocalPort' => $port,
                      'Proto'     => 'tcp',
                      'Type'      => SOCK_STREAM,
                      'Listen'    => SOMAXCONN,
                      'Reuse'     => 1,
                      'Timeout'   => XYLEM_SOCK_TIMEOUT_S);
  $sock_options{'LocalAddr'} = $host if $host;
  my $sock = IO::Socket::INET->new(%sock_options)
    or croak "Failed to create server socket on port $port : $@";

  return $sock;
}

#------------------------------------------------------------------------------

=item get_client_tcp_socket

Get a client TCP socket for communicating with the specified host on the
specified port.

=cut

sub get_client_tcp_socket
{
  my $host = shift or croak "No host specified.";
  my $port = shift or croak "No port specified.";

  my %sock_options = ('PeerAddr' => $host,
                      'PeerPort' => $port,
                      'Proto'    => 'tcp',
                      'Type'     => SOCK_STREAM,
                      'Reuse'     => 1,
                      'Timeout'  => XYLEM_SOCK_TIMEOUT_S);
  my $sock = IO::Socket::INET->new(%sock_options)
    or croak "Failed to create client socket for host $host on port $port: $@";

  $sock->autoflush(1);

  return $sock;
}

#------------------------------------------------------------------------------

=item read_from_socket

Read data from the specified socket, returning a scalar.

=cut

sub read_from_socket
{
  my $sock = shift or die "No socket specified.";
  die "Expected a TCP/IP socket." unless $sock->isa('IO::Socket::INET');

  # Read from the socket.
  my $input = '';
  while (<$sock>) {
    $input .= $_;
  }

  return $input;
}

1;

=back

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
