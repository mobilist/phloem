#!/usr/bin/perl -w

=head1 NAME

release_phloem.pl

=head1 DESCRIPTION

NOT YET WRITTEN!

=head1 SYNOPSIS

release_phloem.pl [options]

=head1 OPTIONS

=over 8

=item B<-h, --help>

Print usage information, and then exit.

=item B<-m, --man>

Print this manual page, and then exit.

=item B<-l, --license>

Print the license terms, and then exit.

=item B<-f, --force>

Force the release, overwriting any existing release with the same version
number.

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

use constant BASE_URL => 'https://phloem.svn.sourceforge.net/svnroot/phloem';

#==============================================================================
# Start of main program.
{
  my ($opt_f);
  Xylem::Utils::Code::process_command_line('f|force' => \$opt_f);

  # Get the current Phloem version number.
  my $phloem_version = $Phloem::Version::VERSION;

  # Assemble some URLs.
  my $tags_url = BASE_URL . '/tags';
  my $release_tag = 'release-' . $phloem_version;
  my $from = BASE_URL . '/trunk';
  my $to = $tags_url . '/' . $release_tag;

  # Check that a release with this version number does not already exist.
  {
    print "Getting the list of Phloem releases...\n";
    my @releases = `svn ls $tags_url`
      // die "Failed to get the list of Phloem releases: $!";
    if (grep(/^$release_tag\//, @releases)) {
      print STDERR
        "WARNING: A release with version number $phloem_version exists.\n",
        "It looks like you forgot to bump the Phloem version number.\n";
      unless ($opt_f) {
        print STDERR
          "If you know what you're doing, then you can use --force.\n",
          "But I'm giving up for now.\n";
        exit(1);
      }
      print STDERR "Ploughing on under --force duress...\n";
      (system("svn rm --force $to") == 0)
        or die "Failed to remove existing Phloem release tag: $!";
    }
  }

  my $message = "Tagging the $phloem_version release of the Phloem project.";
  print $message, "..\n";
  (system("svn copy $from $to -m \"$message\"") == 0)
    or die "Failed to release a new version of Phloem: $!";

  print "Done.\n";
}
# End of main program.
