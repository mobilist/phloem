=head1 NAME

Xylem::Utils::Process

=head1 DESCRIPTION

Utilities for working with processes in Xylem.

=head1 SYNOPSIS

  use Xylem::Utils::Process;
  my $child_pid = Xylem::Utils::Process::spawn_child();

=head1 METHODS

=over 8

=cut

package Xylem::Utils::Process;

use strict;
use warnings;
use diagnostics;

use Carp;
use English;
use File::Spec;
use POSIX qw(setsid);

# Are we running on Win32/Cygwin?
use constant WIN32 => ($OSNAME eq 'MSWin32');

#------------------------------------------------------------------------------

=item spawn_child

Spawn a new child process.

Returns a non-zero PID to the parent process; the child gets a zero return.

=cut

sub spawn_child
{
  # Fork a new child process.
  defined(my $pid = fork) or croak "Failed to fork: $!";

  # The parent process just returns now.
  return $pid if $pid;

  # N.B. The following code won't work on Win32/Cygwin.
  unless (WIN32) {
    # Change the file mode mask.
    umask(0000) or croak "Failed to set file mode mask: $!";

    # Give the child a new process group and session.
    setsid() or croak "Failed to start a new session: $!";
  }

  # Change the working directory to the root.
  my $root_dir = File::Spec->rootdir();
  chdir($root_dir) or croak "Failed to move to $root_dir directory: $!";

  # Redirect file descriptors to the null device.
  my $devnull = File::Spec->devnull();
  open(STDIN, $devnull) or croak "Failed to open $devnull for reading: $!";
  open(STDOUT, ">$devnull") or croak "Failed to open $devnull for writing: $!";
  open(STDERR, '>&STDOUT') or croak "Failed to duplicate STDOUT to STDERR: $!";

  return $pid;
}

1;

=back

=head1 COPYRIGHT

Copyright (C) 2009-2010 Simon Dawson.

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
