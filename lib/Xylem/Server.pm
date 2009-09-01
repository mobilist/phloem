=head1 NAME

Xylem::Server

=head1 DESCRIPTION

Simple server for Xylem.

=head1 SYNOPSIS

  C<use Xylem::Server;>
  C<package DummyServer;>
  C<use base qw(Xylem::Server);>
  C<sub process_request {>
  C<  my $class = shift or die "No class.";>
  C<  my $sock = shift or die "No socket.";>
  C<  print $sock 'Hello there client!';>
  C<}>
  C<package main;>
  C<my $port = 9999;>
  C<my $child_pid = DummyServer->run($port);>

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
use Xylem::Utils::Process;

#------------------------------------------------------------------------------

=item run

Run the server on the specified port.

Spawns a child process, and returns the PID.

N.B. This is a class method.

=cut

sub run
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $port = shift or die "No port specified.";

  # Spawn a new child process to run the component.
  my $child_pid = Xylem::Utils::Process::spawn_child('NODAEMON' => 1);
  return $child_pid if $child_pid;

  # (We're in the child process now.)

  # Create the server socket.
  my $server_sock = IO::Socket::INET->new('LocalPort' => $port,
                                          'Proto'     => 'tcp',
                                          'Type'      => SOCK_STREAM,
                                          'Reuse'     => 1,
                                          'Listen'    => SOMAXCONN,
                                          'Timeout'   => 5,
                                          'Blocking'  => 1)
    or die "Failed to create server socket on port $port : $@\n";

  # Run the server.
  $class->_do_run($server_sock);

  Xylem::Debug->message('Server run ending.');
}

#------------------------------------------------------------------------------
sub process_request
# Process the request on the specified client socket --- "protected" method.
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
    $class->process_request($client_sock);
  }

  close($server_sock);
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
