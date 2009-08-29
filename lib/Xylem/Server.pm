=head1 NAME

Xylem::Server

=head1 SYNOPSIS

  C<use Xylem::Server;>
  C<my $port = 9999;>
  C<Xylem::Server->run($port);>

=head1 METHODS

=over 8

=item run

Run the server on the specified port.

Spawns a child process, and returns the PID.

N.B. This is a class method.

=back

=head1 DESCRIPTION

Simple server for Xylem.

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

package Xylem::Server;

use strict;
use warnings;
use diagnostics;

use IO::Socket::INET;

use lib qw(lib);
use Xylem::Utils::Process;

#------------------------------------------------------------------------------
sub run
# Run the server on the specified port.
#
# Spawns a child process, and returns the PID.
#
# N.B. This is a class method.
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $port = shift or die "No port specified.";

  # Spawn a new child process to run the component.
  my $child_pid = Xylem::Utils::Process::spawn_child();
  return $child_pid if $child_pid;

  # (We're in the child process now.)

  my $server_sock = IO::Socket::INET->new('LocalPort' => $port,
                                          'Proto'     => 'tcp',
                                          'Type'      => SOCK_STREAM,
                                          'Reuse'     => 1,
                                          'Listen'    => SOMAXCONN)
    or die "Failed to create server socket on port $port : $@\n";

  while (my $client_sock = $server_sock->accept()) {
    $class->process_request($client_sock);
  }

  close($server_sock);
}

#------------------------------------------------------------------------------
sub process_request
# Process the request on the specified client socket --- "protected" method.
#
# N.B. This is a class method.
{
  die "PURE VIRTUAL BASE CLASS METHOD! MUST BE OVERRIDDEN!";
}

1;
