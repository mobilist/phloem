#!/usr/bin/perl -w

=head1 NAME

check_code.pl

=head1 DESCRIPTION

Check the code for some common problems.

=head1 SYNOPSIS

check_code.pl [options]

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
use Pod::Usage;

use lib qw(lib);
use Xylem::Utils::Code;
use Xylem::Utils::File;

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
    check_code.pl Copyright (C) 2009 Simon Dawson
    This program comes with ABSOLUTELY NO WARRANTY.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type check_code.pl --license for details.
xxx_END_GPL_HEADER

  # Initialise a standard error code.
  my $err_code = 0;

  my $user_sub = sub {
    my $file = shift;

    # Check the file, and return immediately if it is okay.
    return if Xylem::Utils::Code::check_code_file($file);

    # Update the overall error code, if we haven't seen an error yet.
    $err_code ||= 1;
  };
  Xylem::Utils::File::find($user_sub);

  exit($err_code);
}
# End of main program.
