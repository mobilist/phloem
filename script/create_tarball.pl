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
use File::Find;
use Getopt::Long;
use Pod::Usage;

use constant ARCHIVE_FILE_NAME => 'phloem.tar.gz';

#==============================================================================
# Start of main program.
{
  my ($opt_h, $opt_m, $opt_l);
  pod2usage(-verbose => 0) unless GetOptions('h|help'    => \$opt_h,
                                             'm|man'     => \$opt_m,
                                             'l|license' => \$opt_l);
  pod2usage(-verbose => 1) if $opt_h;
  pod2usage(-verbose => 2) if $opt_m;
  pod2usage(-verbose  => 99,
            -sections => 'NAME|COPYRIGHT|LICENSE',
            -exitval  => 0) if $opt_l;

  print STDERR <<'xxx_END_GPL_HEADER';
    create_tarball.pl Copyright (C) 2009 Simon Dawson
    This program comes with ABSOLUTELY NO WARRANTY.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type create_tarball.pl --license for details.
xxx_END_GPL_HEADER

  die "Archive file already exists." if (-f ARCHIVE_FILE_NAME);

  my $tar = Archive::Tar->new()
    or die "Failed to create archive: " . $Archive::Tar::error;

  my @files;

  my $wanted_sub = sub {
    return unless (-f $File::Find::name);

    return if ($File::Find::name =~ /\.svn\W/o); # Skip subversion stuff.

    return if ($File::Find::name =~ /~$/o); # Skip backup files.

    return if ($File::Find::name =~ /\.log$/o); # Skip log files.

    return unless (-T $File::Find::name); # Skip non-text files.

    push(@files, $File::Find::name);
  };
  find({'wanted' => $wanted_sub, 'no_chdir' => 1}, '.');

  $tar->add_files(@files) or die "Failed to add files: " . $tar->error();

  $tar->write(ARCHIVE_FILE_NAME, COMPRESS_GZIP, 'phloem')
    or die "Failed to write archive: " . $tar->error();

  print "Created archive ", ARCHIVE_FILE_NAME, "\n";
}
# End of main program.
