#!/usr/bin/perl -w

=head1 NAME

phloem.pl

=head1 DESCRIPTION

Driver script for Phloem.

=head1 SYNOPSIS

phloem.pl [options]

=head1 OPTIONS

=over 8

=item B<-h, --help>

Print usage information, and then exit.

=item B<-m, --man>

Print this manual page, and then exit.

=item B<-l, --license>

Print the license terms, and then exit.

=item B<-d, --debug>

Enable debugging output.

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
use Phloem::App;
use Xylem::Utils::Code;

#==============================================================================
# Start of main program.
{
  my ($opt_d);
  Xylem::Utils::Code::process_command_line('d|debug' => \$opt_d);

  # Run the application.
  Phloem::App->run('DEBUG' => $opt_d);
}
# End of main program.
