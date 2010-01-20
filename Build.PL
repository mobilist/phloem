#!/usr/bin/perl -w

=head1 NAME

Build.PL

=head1 DESCRIPTION

Build script for Phloem.

=head1 SYNOPSIS

Build.PL [options]

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

Copyright (C) 2009-2010 Simon Dawson.

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
use Module::Build;

use lib qw(t/lib lib);
use Phloem::Version;
use Xylem::Utils::Code;
use Xylem::Utils::File;

#==============================================================================
# Start of main program.
{
  Xylem::Utils::Code::process_command_line();

  # Generate a MANIFEST.SKIP file.
  {
    my $manifest_skip_content = <<'xxx_END_MANIFEST_SKIP_CONTENT';
^_build
^Build$
^blib
~$
\.bak$
\.log$
^MANIFEST\.SKIP$
CVS
\.svn\W
xxx_END_MANIFEST_SKIP_CONTENT
    Xylem::Utils::File::write('MANIFEST.SKIP', $manifest_skip_content);
  }

  # N.B. We're a bit sneaky here: there is no version number in Phloem::Manual.
  #      (Indeed, the only version number anywhere in Phloem is the one
  #      specified in the Phloem::Version module.)
  #
  #      We [ab]use the 'dist_version_from' parameter to tell the build script
  #      where to get the information from for the README file.
  my $manual_file = File::Spec->catfile('lib', 'Phloem', 'Manual.pm');
  my $builder = Module::Build->new(
    'dist_name'     => 'Phloem',
    'dist_version'  => $Phloem::Version::VERSION,
    'dist_abstract' => 'The Phloem Content Delivery Network (CDN) application',
    'dist_version_from' => $manual_file,
    'create_readme' => 1,
    'dist_author'   => 'Simon Dawson <spdawson@gmail.com>',
    'license'       => 'gpl',
    'requires'      => {'perl'             => '5.10.0',
                        'App::Prove'       => 0,
                        'Badger'           => 0,
                        'Archive::Tar'     => 1.46, # For COMPRESS_GZIP.
                        'File::Path'       => 2.06_05, # For make_path().
                        'File::Rsync'      => 0,
                        'Mail::Sendmail'   => 0.75, # To send attachments.
                        'Module::CoreList' => 2.17, # To work properly with $].
                        'XML::Simple'      => 0},
    'create_makefile_pl'   => 'passthrough',
    'recursive_test_files' => 1,
    'script_files'         => [qw(script/phloem.pl)]);

  $builder->create_build_script();
}
# End of main program.
