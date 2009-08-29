=head1 NAME

Phloem::Logger

=head1 SYNOPSIS

  C<use Phloem::Logger;>
  C<Phloem::Logger->clear();>
  C<Phloem::Logger->append('Hello teh world!');>

=head1 METHODS

=over 8

=item append

Append the specified message to the log file.

=item clear

Clear the log file.

=back

=head1 DESCRIPTION

Logging utilities for Phloem.

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

package Phloem::Logger;

use strict;
use warnings;
use diagnostics;

use Fcntl qw(:flock :seek); # Import LOCK_* and SEEK_* constants.
use FileHandle;

use lib qw(lib);
use Phloem::Constants;
use Xylem::TimeStamp;

#------------------------------------------------------------------------------
sub append
# Append the specified message to the log file.
{
  # Get the input: a message to log.
  my $message = shift or die "No message specified.";
  chomp($message);

  # Generate a time-stamp.
  my $ts = Xylem::TimeStamp::create();
 
  # Assemble the message: prefix it with the time-stamp.
  $message = "$ts --- $message\n";

  # Print the message to the console too.
  #
  # N.B. We need to use standard error in case we are called from a CGI script.
  print STDERR $message;

  my $log_file = $Phloem::Constants::LOG_FILE;
  my $log_fh = FileHandle->new(">> $log_file")
    or die "Failed to open log file for appending: $!";
  flock($log_fh, LOCK_EX) or die "Failed to acquire exclusive file lock: $!";

  # Append to the log.
  print $log_fh $message;

  flock($log_fh, LOCK_UN) or die "Failed to unlock file: $!";
  $log_fh->close() or die "Failed to close file: $!";
}

#------------------------------------------------------------------------------
sub clear
# Clear the log file.
{
  my $log_file = $Phloem::Constants::LOG_FILE;
  my $log_fh = FileHandle->new("> $log_file")
    or die "Failed to open log file for writing: $!";
  flock($log_fh, LOCK_EX) or die "Failed to acquire exclusive file lock: $!";

  # Clear the log.
  $log_fh->seek(SEEK_SET, 0);
  $log_fh->truncate(0);

  flock($log_fh, LOCK_UN) or die "Failed to unlock file: $!";
  $log_fh->close() or die "Failed to close file: $!";
}

1;
