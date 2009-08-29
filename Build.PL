#!/usr/bin/perl -w

=head1 NAME

Build.PL

=head1 SYNOPSIS

Build.PL [options]

=head1 DESCRIPTION

Build script for Phloem.

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

use Getopt::Long;
use Module::Build;
use Pod::Usage;

#==============================================================================
# Start of main program.
{
  my ($opt_h, $opt_m, $opt_l);
  pod2usage(-verbose => 0) unless GetOptions('h|help'     => \$opt_h,
                                             'm|man'      => \$opt_m,
                                             'l|license'  => \$opt_l);
  pod2usage(-verbose => 1) if $opt_h;
  pod2usage(-verbose => 2) if $opt_m;
  pod2usage(-verbose  => 99,
            -sections => 'NAME|COPYRIGHT|LICENSE',
            -exitval  => 0) if $opt_l;

  print <<'xxx_END_GPL_HEADER';
    Build.PL Copyright (C) 2009 Simon Dawson
    This program comes with ABSOLUTELY NO WARRANTY.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type Build.PL --license for details.
xxx_END_GPL_HEADER

  my $builder =
    Module::Build->new('module_name' => 'Phloem::App',
                       'dist_author' => 'Simon Dawson <spdawson@gmail.com>',
                       'license'     => 'gpl',
                       'requires'    => {'perl'        => '5.10.0',
                                         'XML::Simple' => 0},
                       'recursive_test_files' => 1);

  $builder->create_build_script();
}
# End of main program.
