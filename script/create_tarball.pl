#!/usr/bin/perl -w

=head1 NAME

create_tarball.pl

=head1 DESCRIPTION

Create a distribution tarball.

=head1 SYNOPSIS

create_tarball.pl [options]

=head1 OPTIONS

=over 8

=item B<-h, --help>

Print usage information, and then exit.

=item B<-m, --man>

Print this manual page, and then exit.

=item B<-l, --license>

Print the license terms, and then exit.

=back

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

use strict;
use warnings;
use diagnostics;

use Archive::Tar;

use lib qw(lib);
use Phloem::Version;
use Xylem::Utils::Code;
use Xylem::Utils::File;

# This file name contains a place-holder for the Phloem version number.
use constant ARCHIVE_FILE_NAME => 'phloem-$VERSION.tar.gz';

#==============================================================================
# Start of main program.
{
  Xylem::Utils::Code::process_command_line();

  # Put together the archive file name, using the Phloem version number.
  my $archive_file_name = ARCHIVE_FILE_NAME;
  $archive_file_name =~ s/\$VERSION/$Phloem::Version::VERSION/o;
  die "Archive file already exists." if (-f $archive_file_name);

  my $tar = Archive::Tar->new()
    or die "Failed to create archive: " . $Archive::Tar::error;

  my @files;

  my $user_sub = sub {
    my $file = shift;

    push(@files, $file);
  };
  Xylem::Utils::File::find($user_sub);

  $tar->add_files(@files) or die "Failed to add files: " . $tar->error();

  $tar->write($archive_file_name, COMPRESS_GZIP, 'phloem')
    or die "Failed to write archive: " . $tar->error();

  print "Created archive ", $archive_file_name, "\n";
}
# End of main program.
