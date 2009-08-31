=head1 NAME

Xylem::Server::Fork

=head1 DESCRIPTION

A simple forking server for Xylem.

=head1 SYNOPSIS

  C<use Xylem::Server::Fork;>

=cut

package Xylem::Server::Fork;

use strict;
use warnings;
use diagnostics;

use lib qw(lib);

use base qw(Xylem::Server);

#------------------------------------------------------------------------------
sub _do_run
# Run the server --- "protected" method.
#
# N.B. This is a class method.
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $server_sock = shift or die "No server socket specified.";
  die "Expected a TCP/IP socket." unless $server_sock->isa('IO::Socket::INET');

  use POSIX qw(:sys_wait_h);

  sub REAPER {
    print STDERR "DEBUG: In reaper.\n";
    1 until (-1 == waitpid(-1, WNOHANG));
    $SIG{'CHLD'} = \&REAPER; # unless $] >= 5.002
  }

  local $SIG{'CHLD'} = \&REAPER;

  while (my $client_sock = $server_sock->accept()) {

    next if my $pid = fork; # Parent re-enters the loop (via the continue block).
    die "Failed to fork: $!" unless defined($pid);

    # This is the child process.

    # Child process closes unused socket handle.
    close($server_sock);

    select($client_sock->fileno);
    $client_sock->autoflush(1);

    open(STDIN, "<<&" . $client_sock->fileno) or die "can't dup client: $!";
    open(STDOUT, ">&" . $client_sock->fileno) or die "can't dup client: $!";
    open(STDERR, ">&" . $client_sock->fileno) or die "can't dup client: $!";

    # Handle the request.
    $class->process_request($client_sock);

    close($client_sock); # Child has finished with this now.
    exit(0); # Don't let the child back to accept!
  } continue {
    close($client_sock); # Parent process closes unused socket handle.
  }

  die "Server run ending.";
}

1;

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
