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

use lib qw(lib);
use Xylem::Utils::Code;
use Xylem::Utils::File;

#==============================================================================
# Start of main program.
{
  Xylem::Utils::Code::process_command_line();

  # Initialise a standard error code.
  my $err_code = 0;

  my $user_sub = sub {
    my $file = shift;

    # Check the file, and return immediately if it is okay.
    return if Xylem::Utils::Code::check_code_file($file,
                                                  'WARNINGS_AS_ERRORS' => 1);

    # Update the overall error code, if we haven't seen an error yet.
    $err_code ||= 1;
  };
  Xylem::Utils::File::find($user_sub);

  exit($err_code);
}
# End of main program.
