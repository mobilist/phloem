=head1 NAME

Xylem::Server

=head1 DESCRIPTION

Simple server for Xylem.

=head1 SYNOPSIS

  use Xylem::Server;
  package DummyServer;
  use base qw(Xylem::Server);
  sub process_request {
    my $class = shift or die "No class.";
    my $sock = shift or die "No socket.";
    print $sock 'Hello there client!';
  }
  package main;
  my $port = 9999;
  my $child_pid = DummyServer->run($port);

=head1 METHODS

=over 8

=cut

package Xylem::Server;

use strict;
use warnings;
use diagnostics;

use IO::Socket::INET;

use lib qw(lib);
use Xylem::Debug;
use Xylem::Utils::Net;
use Xylem::Utils::Process;

#------------------------------------------------------------------------------

=item run

Run the server on the specified port.

A hash reference of options can optionally be specified, as the second
argument. This can include the 'host' (server host name/address) and 'daemon'
(flag --- seee below) entries.

By default, the server runs as a daemon: this method spawns a child process
and returns the PID. However, if the 'daemon' flag is explicitly set down,
then the server will be run in-process.

N.B. This is a class method.

=cut

sub run
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $port = shift or die "No port specified.";
  my $args_hash = shift || {}; # Optional second argument.
  die "Expected a hash reference." unless (ref($args_hash) eq 'HASH');

  # Did we get a host name/address?
  my $host;
  $host = $args_hash->{'host'} if exists($args_hash->{'host'});

  # Is the daemon flag up? (The flag is up by default.)
  my $daemon = 1;
  $daemon = $args_hash->{'daemon'} if exists($args_hash->{'daemon'});

  # Spawn a new child process to run the server, if running as a daemon.
  if ($daemon) {
    my $child_pid = Xylem::Utils::Process::spawn_child();
    return $child_pid if $child_pid;
  }

  # (We're in the child process now, if we're running as a daemon.)

  # Create the server socket.
  my $server_sock = Xylem::Utils::Net::get_server_tcp_socket($port, $host)
    or die "Failed to create server socket on port $port.";

  # Run the server.
  $class->_do_run($server_sock);

  Xylem::Debug->message('Server run ending.');

  $server_sock->shutdown(2) or die "Failed to shut down server socket: $!";
}

#------------------------------------------------------------------------------
sub process_request
# Process the request on the specified client socket --- "protected" method.
#
# Subclasses must provide an implementation for this pure virtual method.
#
# N.B. This is a class method.
{
  die "PURE VIRTUAL BASE CLASS METHOD! MUST BE OVERRIDDEN!";
}

#------------------------------------------------------------------------------
sub _do_run
# Run the server --- "protected" method.
#
# Subclasses should override this default implementation if different
# behaviour is required.
#
# N.B. This is a class method.
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $server_sock = shift or die "No server socket specified.";
  die "Expected a TCP/IP socket." unless $server_sock->isa('IO::Socket::INET');

  while (my $client_sock = $server_sock->accept()) {
    $client_sock->autoflush(1);
    $class->process_request($client_sock);
    $client_sock->shutdown(2) or die "Failed to shut down client socket: $!";
  }
}

1;

=back

=head1 SEE ALSO

L<Xylem::Server::Fork>

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
