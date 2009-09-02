=head1 NAME

Xylem::Utils::File

=head1 DESCRIPTION

File utilities for Xylem.

=head1 SYNOPSIS

  C<use Xylem::Utils::File;>

=head1 METHODS

=over 8

=cut

package Xylem::Utils::File;

use strict;
use warnings;
use diagnostics;

use Fcntl qw(:seek); # Import SEEK_* constants.

use lib qw(lib);
use Xylem::FileLocker;

#------------------------------------------------------------------------------

=item append_line

Append the specified line to the specified file.

=cut

sub append_line
{
  # Get the input: a line to append.
  my $line = shift or die "No line specified.";
  chomp($line);

  my $file = shift or die "No file specified.";

  # Append to the file.
  {
    # Lock the file.
    my $file_lock = Xylem::FileLocker->new($file, 'a');

    my $fh = $file_lock->filehandle();

    print $fh "$line\n";
  }
}

#------------------------------------------------------------------------------

=item clear

Clear the specified file.

=cut

sub clear
{
  my $file = shift or die "No file specified.";

  # Nothing to do if the file does not exist.
  return unless (-f $file);

  # Clear the file.
  {
    # Lock the file.
    my $file_lock = Xylem::FileLocker->new($file, 'w');

    my $fh = $file_lock->filehandle();

    $fh->seek(SEEK_SET, 0);
    $fh->truncate(0);
  }
}

#------------------------------------------------------------------------------

=item read

Read the specified file.

=cut

sub read
{
  my $file = shift or die "No file specified.";

  # Nothing to do if the file does not exist.
  return unless (-f $file);

  # Read the file.
  my $content;
  {
    # Lock the file.
    my $file_lock = Xylem::FileLocker->new($file, 'r');

    my $fh = $file_lock->filehandle();

    $content = <$fh>;
  }

  return $content;
}

#------------------------------------------------------------------------------

=item write

To the specified file, write the specified data.

=cut

sub write
{
  my $file = shift or die "No file specified.";
  my $content = shift or die "No file content specified.";

  {
    # Lock the file.
    my $file_lock = Xylem::FileLocker->new($file, 'w');

    my $fh = $file_lock->filehandle();

    # Write to the file.
    print $fh $content;
  }
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
