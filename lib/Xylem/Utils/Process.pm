=head1 NAME

Xylem::Utils::Process

=head1 SYNOPSIS

  C<use Xylem::Utils::Process;>
  C<my $child_pid = Xylem::Utils::Process::spawn_child();>

=head1 METHODS

=over 8

=item spawn_child

Spawn a new child process.

Returns a non-zero PID to the parent process; the child gets a zero return.

The default behaviour is to fully "daemonise" the child --- the working
directory is changed to the root, and standard file descriptors are
redirected to /dev/null. If this behaviour is not required, then a
'NODAEMON' flag argument should be provided by the caller.

=back

=head1 DESCRIPTION

Utilities for working with processes in Xylem.

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

package Xylem::Utils::Process;

use strict;
use warnings;
use diagnostics;

use POSIX qw(setsid);

use lib qw(lib);

#------------------------------------------------------------------------------
sub spawn_child
# Spawn a new child process.
#
# Returns a non-zero PID to the parent process; the child gets a zero return.
#
# The default behaviour is to fully "daemonise" the child --- the working
# directory is changed to the root, and standard file descriptors are
# redirected to /dev/null. If this behaviour is not required, then a
# 'NODAEMON' flag argument should be provided by the caller.
{
  # Are we to fully "daemonise" the child?
  my %args = @_;
  my $NODAEMON = exists($args{'NODAEMON'}) && $args{'NODAEMON'};

  # Fork a new child process.
  defined(my $pid = fork) or die "Failed to fork: $!";

  # The parent process just returns now.
  return $pid if $pid;

  # Give the child a new process group and session.
  setsid() or die "Failed to start a new session: $!";

  unless ($NODAEMON) {
    # Change the working directory to the root.
    chdir('/') or die "Failed to move to /: $!";

    # Redirect file descriptors to /dev/null.
    open(STDIN, '/dev/null') or die "Failed to open /dev/null for reading: $!";
    open(STDOUT, '>/dev/null')
      or die "Failed to open /dev/null for writing: $!";
    open(STDERR, '>&STDOUT') or die "Failed to duplicate STDOUT to STDERR: $!";
  }

  return $pid;
}

1;
