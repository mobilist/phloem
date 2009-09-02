=head1 NAME

Xylem::FileLocker

=head1 DESCRIPTION

A simple file locker class.

The specified file is locked, with the specified mode, while the class
instance is extant.

When the object goes out of scope or is undefined, the file lock is
automatically released.

This might be useful for managing concurrent access to a file-based database,
or for concurrent logging to a single file, for example.

=head1 SYNOPSIS

  C<use Xylem::FileLocker;>
  C<# Enter the scope within which a file is to be locked.>
  C<{>
  C<  my $locker = Xylem::FileLocker->new('/etc/passwd', 'a');>
  C<  # Append to the locked file...>
  C<  my $fh = $locker->filehandle();>
  C<  print $fh "root:x:0:0:root:/root:/bin/bash\n";>
  C<  # File is automatically unlocked when $locker goes out of scope.>
  C<}>

=head1 METHODS

=over 8

=cut

package Xylem::FileLocker;

use strict;
use warnings;
use diagnostics;

use Fcntl qw(:flock); # Import LOCK_* constants.
use FileHandle;

use lib qw(lib);

#------------------------------------------------------------------------------

=item new

Constructor.

Expects exactly two arguments: the file path to be locked, and an access mode.

The access mode can be 'r' for a read (i.e., shared) lock, 'w' for a write
(i.e., exclusive) lock, or 'a' for an append (i.e., exclusive) lock.

=cut

sub new
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $file = shift or die "A file path must be specified.";
  die "Expected an ordinary scalar." if ref($file);

  my $mode = shift;
  die "Expected an ordinary scalar." if ref($mode);
  die "An access mode of 'r', 'w' or 'a' must be specified."
    unless ($mode && $mode =~ /^(?:r|w|a)$/o);

  print STDERR "DEBUG: Acquiring lock on file $file.\n";
  # N.B. It's a shame that we have to open the file in order to get a lock.
  my $raw_mode = ($mode eq 'r') ? '<' : ( ($mode eq 'w') ? '>' : '>>');
  my $fh = FileHandle->new("$raw_mode " . $file)
    or die "Failed to open $file: $!";

  # Acquire the lock.
  #
  # N.B. These are blocking calls; non-blocking calls won't do what we want.
  if ($mode eq 'r') {
    flock($fh, LOCK_SH) or die "Failed to acquire shared lock on $file: $!";
  } else {
    flock($fh, LOCK_EX) or die "Failed to acquire exclusive lock on $file: $!";
  }

  # Set up the object data.
  #
  # N.B. We only need to store the file handle, so the object is light-weight.
  my $self = {'_FILEHANDLE' => $fh};

  return bless($self, $class);
}

#------------------------------------------------------------------------------

=item

Get the locked filehandle.

=cut

sub filehandle
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->{'_FILEHANDLE'};
}

#------------------------------------------------------------------------------
sub DESTROY
# Destructor.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  print STDERR "DEBUG: Releasing file lock.\n";
  my $fh = $self->filehandle();
  flock($fh, LOCK_UN) or die "Failed to unlock file: $!";

  # N.B. Don't forget to close the file, which (irritatingly) we had to open.
  #
  #      Strictly speaking, we don't have to do this: the file will be closed
  #      automatically as soon as the cached file handle reference goes out of
  #      scope on leaving the destructor. However, this is just good practice.
  $fh->close() or die "Failed to close file: $!";
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