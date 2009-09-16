=head1 NAME

Xylem::Utils::File

=head1 DESCRIPTION

File utilities for Xylem.

=head1 SYNOPSIS

  use Xylem::Utils::File;

  Xylem::Utils::File::append_line('Hello teh World!', 'some/file.txt');
  Xylem::Utils::File::clear('some/file.txt');
  my $content = Xylem::Utils::File::read('some/file.txt');
  Xylem::Utils::File::write('some/other/file.txt', $content);
  Xylem::Utils::File::find( sub { my $file = shift; print "Saw $file\n"; } );

=head1 METHODS

=over 8

=cut

package Xylem::Utils::File;

use strict;
use warnings;
use diagnostics;

use Archive::Tar 1.46; # For COMPRESS_GZIP.
use Carp;
use English;
use Fcntl qw(:seek); # Import SEEK_* constants.
use File::Find qw(); # Do not import anything.

use Xylem::FileLocker;

#------------------------------------------------------------------------------

=item append_line

Append the specified line to the specified file.

=cut

sub append_line
{
  # Get the input: a line to append.
  my $line = shift or croak "No line specified.";
  chomp($line);

  my $file = shift or croak "No file specified.";

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
  my $file = shift or croak "No file specified.";

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

Read the specified file, slurping the entire contents into a scalar.

=cut

sub read
{
  my $file = shift or croak "No file specified.";

  # Nothing to do if the file does not exist.
  return unless (-f $file);

  # Read the file.
  my $content;
  {
    # Lock the file.
    my $file_lock = Xylem::FileLocker->new($file, 'r');

    # Enable localised slurp mode.
    local $INPUT_RECORD_SEPARATOR; # Or $/, if you prefer.
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
  my $file = shift or croak "No file specified.";
  my $content = shift or croak "No file content specified.";

  {
    # Lock the file.
    my $file_lock = Xylem::FileLocker->new($file, 'w');

    my $fh = $file_lock->filehandle();

    # Write to the file.
    print $fh $content;
  }
}

#------------------------------------------------------------------------------

=item find

Find relevant files under the current working directory.

For each file found, call the specified subroutine reference with the full
file path as the single argument.

=cut

sub find
{
  my $user_sub = shift or croak "No subroutine specified.";
  croak "Expected a subroutine reference." unless (ref($user_sub) eq 'CODE');

  my $wanted_sub = sub {
    return unless (-f $File::Find::name);

    return if ($File::Find::name =~ /\.svn\W/o); # Skip subversion stuff.

    return if ($File::Find::name =~ /~$/o); # Skip backup files.

    return if ($File::Find::name =~ /\.log$/o); # Skip log files.

    return unless (-T $File::Find::name); # Skip non-text files.

    # Call the user-specified subroutine.
    return $user_sub->($File::Find::name);
  };
  File::Find::find({'wanted' => $wanted_sub, 'no_chdir' => 1}, '.');
}

#------------------------------------------------------------------------------

=item strip_cr

Strip carriage returns out of the specified file, replacing \r\n with \n
globally.

N.B. This will modify the specified file in place.

=cut

sub strip_cr
{
  my $file = shift or croak "No file specified.";

  # N.B. Disambiguate from CORE::read().
  my $content = Xylem::Utils::File::read($file);

  $content =~ s/\r\n/\n/og;

  # N.B. Disambiguate from CORE::write().
  Xylem::Utils::File::write($file, $content);
}

#------------------------------------------------------------------------------

=item create_archive

Create the specified compressed archive file, adding the specified files to it.

The first argument is the archive file path to create. The second argument is
an array reference of the file paths to add the the archive.

The third argument is an optional "prefix" string which will be used as an
ersatz top-level directory in the archive.

=cut

sub create_archive
{
  my $archive_file_name = shift or croak "No archive file name specified.";
  my $files_arrayref = shift or croak "No files to archive.";
  my $archive_prefix = shift || undef; # Undef if we get an empty string or 0.

  # Sanity checking.
  croak "Expected an array reference."
    unless (ref($files_arrayref) eq 'ARRAY');

  my $tar = Archive::Tar->new()
    or croak "Failed to create archive: " . $Archive::Tar::error;

  $tar->add_files(@$files_arrayref)
    or croak "Failed to add files: " . $tar->error();

  $tar->write($archive_file_name, COMPRESS_GZIP, $archive_prefix)
    or croak "Failed to write archive: " . $tar->error();
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
