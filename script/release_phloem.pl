#!/usr/bin/perl -w

=head1 NAME

release_phloem.pl

=head1 DESCRIPTION

Make a new release of Phloem, using the current code-base.

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

=item B<-s, --simulate>

Don't actually do anything; just simulate what would be done.

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

use File::Spec;

use lib qw(lib);
use Phloem::Version;
use Xylem::Utils::Code;
use Xylem::Utils::File;

use constant BASE_URL  => 'https://phloem.svn.sourceforge.net/svnroot/phloem';
use constant DEVELOPER => 'sconedog';

#==============================================================================
# Start of main program.
{
  my ($opt_f, $opt_s);
  Xylem::Utils::Code::process_command_line('f|force'    => \$opt_f,
                                           's|simulate' => \$opt_s);

  # Get the current Phloem version number.
  my $phloem_version = $Phloem::Version::VERSION;

  # Assemble some URLs.
  my $tags_url = BASE_URL . '/tags';
  my $release_tag = 'release-' . $phloem_version;
  my $from = BASE_URL . '/trunk';
  my $to = $tags_url . '/' . $release_tag;

  # Check that the change log file contains an entry for the release.
  {
    print "Checking the change log...\n";
    my $change_log = Xylem::Utils::File::read('Changes');
    my $version_number = $phloem_version;
    $version_number=~ s/^v//o; # Remove leading 'v'.
    unless ($change_log =~ /\b$version_number\b/o) {
      print STDERR
        "ERROR: It looks like you forgot to update the change log.\n";
      exit(1);
    }
  }

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
      if ($opt_s) {
        print "Simulate mode: svn rm --force $to\n";
      } else {
        (system("svn rm --force $to") == 0)
          or die "Failed to remove existing Phloem release tag: $!";
      }
    }
  }

  # Create the subversion tag for the release.
  {
    my $message = "Tagging the $phloem_version release of the Phloem project.";
    print $message, "..\n";
    if ($opt_s) {
      print "Simulate mode: svn copy $from $to -m \"$message\"\n";
    } else {
      (system("svn copy $from $to -m \"$message\"") == 0)
        or die "Failed to release a new version of Phloem: $!";
    }
  }

  # Create a tarball of the release, and upload it to the project host.
  _upload_release_tarball($opt_f, $opt_s, $phloem_version);

  print "Done.\n";
}
# End of main program; subroutines follow.

#------------------------------------------------------------------------------
sub _upload_release_tarball
# Create a tarball of the release, and upload it to the project host.
{
  # Get the inputs: "force" and "simulate" flags, and a version number.
  my ($opt_f, $opt_s, $phloem_version) = @_;

  # Create the tarball.
  my $archive_file_name;
  {
    print "Creating release tarball...\n";
    my $create_command = './script/create_tarball.pl';
    $create_command .= ' --force' if $opt_f; # Force, if appropriate.
    $create_command .= ' 2>' . File::Spec->devnull(); # Discard standard error.
    my @caught_output;
    if ($opt_s) {
      print "Simulate mode: $create_command\n";
      $archive_file_name = 'dummy.tar.gz'; # N.B. For simulation purposes only.
    } else {
      @caught_output = `$create_command` or die "Failed to create tarball.";
    }

    # Attempt to get the archive file name.
    foreach my $current_line (@caught_output) {
      if ($current_line =~ /^Created archive (.*)$/o) {
        $archive_file_name = $1;
        last;
      }
    }
  }
  die "Failed to get archive file name." unless $archive_file_name;

  # Attempt to upload the release tarball to the project host.
  print "Uploading $archive_file_name to project host...\n";
  my $upload_command =
    "scp $archive_file_name " . DEVELOPER . '@frs.sourceforge.net:' .
    '/home/frs/project/p/ph/phloem/releases';
  if ($opt_s) {
    print "Simulate mode: $upload_command\n";
  } else {
    (system($upload_command) == 0)
      or die "Failed to upload tarball to project host: $!";
  }

  # Clean up after ourself.
  if ($opt_s) {
    print "Simulate mode: unlink($archive_file_name)\n";
  } else {
    unlink($archive_file_name)
      or die "Failed to delete file $archive_file_name: $!";
  }
}
