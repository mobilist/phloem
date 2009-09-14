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

use lib qw(lib);
use Phloem::Version;
use Xylem::Utils::Code;
use Xylem::Utils::File;

use constant ARCHIVE_PREFIX => 'phloem';

#==============================================================================
# Start of main program.
{
  Xylem::Utils::Code::process_command_line();

  # Put together the archive file name, using the Phloem version number.
  my $archive_file_name = ARCHIVE_PREFIX . '-' . $Phloem::Version::VERSION;

  my @files;
  Xylem::Utils::File::find( sub { push(@files, shift) } );

  Xylem::Utils::File::create_archive($archive_file_name,
                                     ARCHIVE_PREFIX,
                                     \@files);

  print "Created archive ", $archive_file_name, "\n";
}
# End of main program.
