=head1 NAME

Xylem::Server::Fork

=head1 DESCRIPTION

A simple forking server for Xylem.

=head1 SYNOPSIS

  use Xylem::Server::Fork;
  use constant PORT => 9999;
  Xylem::Server::Fork->run(PORT);

=cut

package Xylem::Server::Fork;

use strict;
use warnings;
use diagnostics;

use Carp;
use POSIX qw(:sys_wait_h);

use Xylem::Debug;

use base qw(Xylem::Server);

#------------------------------------------------------------------------------
sub _do_run
# Run the server --- "protected" method.
#
# N.B. This is a class method.
{
  my $class = shift or croak "No class name specified.";
  croak "Expected an ordinary scalar." if ref($class);
  croak "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $server_sock = shift or croak "No server socket specified.";
  croak "Expected a TCP/IP socket."
    unless $server_sock->isa('IO::Socket::INET');

  sub REAPER {
    Xylem::Debug->message('In reaper');
    1 until (-1 == waitpid(-1, WNOHANG));
  }

  local $SIG{'CHLD'} = \&REAPER;

  while (my $client_sock = $server_sock->accept()) {

    # Fork a new child process.
    defined(my $pid = fork) or croak "Failed to fork: $!";

    # The parent process just re-enters the loop.
    if ($pid) {
      close($client_sock); # Parent process closes unused client socket handle.
      next;
    }

    # (We're in the child process now.)

    # Child process closes unused server socket handle.
    close($server_sock);

    select($client_sock->fileno);
    $client_sock->autoflush(1);

    open(STDIN, "<<&" . $client_sock->fileno) or croak "can't dup client: $!";
    open(STDOUT, ">&" . $client_sock->fileno) or croak "can't dup client: $!";
    open(STDERR, ">&" . $client_sock->fileno) or croak "can't dup client: $!";

    # Handle the request.
    $class->process_request($client_sock);

    # Child process has finished with the client socket now.
    $client_sock->shutdown(2) or croak "Failed to shut down client socket: $!";
    exit(0); # Don't let the child process back to accept!
  }
}

1;

=head1 SEE ALSO

L<Xylem::Server>

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
