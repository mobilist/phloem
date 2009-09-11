#!/usr/bin/perl -w

=head1 NAME

run_tests.pl

=head1 DESCRIPTION

Run the Phloem tests.

Yes, this could have just been a simple shell script one-liner --- a wrapper
around the "prove" command. But that would have made Phloem less portable.
And, in any case, this whole thing is meant to be written in Perl.

=head1 SYNOPSIS

run_tests.pl [options]

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

use App::Prove;

use lib qw(lib);
use Xylem::Utils::Code;

#==============================================================================
# Start of main program.
{
  Xylem::Utils::Code::process_command_line();

  # Set up the tester object.
  my $app = App::Prove->new();
  $app->lib(1);
  $app->verbose(1);
  $app->recurse(1);
  $app->timer(1);
  $app->process_args('t'); # Test directory path.

  # Return a proper exit code.
  exit( $app->run() ? 0 : 1 );
}
# End of main program.
