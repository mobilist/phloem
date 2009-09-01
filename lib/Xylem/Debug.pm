=head1 NAME

Xylem::Debug

=head1 DESCRIPTION

Debugging utilities for Xylem.

=head1 SYNOPSIS

  C<use Xylem::Debug;>

=head1 METHODS

=over 8

=cut

package Xylem::Debug;

use strict;
use warnings;
use diagnostics;

use lib qw(lib);

# A flag variable to store the current debug status (enabled/disabled).
my $_DEBUG;

#------------------------------------------------------------------------------

=item enabled

Enable/disable debugging. If no argument is passed, returns the current status:
enabled (true) or disabled (false).

=cut

sub enabled
{
  my $value = shift;
  $_DEBUG = $value if defined($value);
  return $_DEBUG;
}

#------------------------------------------------------------------------------

=item message

Print the specified debugging message.

=cut

sub message
{
  return 1 unless enabled();

  chomp(my $message = shift // '');

  print STDERR "DEBUG: $message\n";
}

1;

=back

=head1 COPYRIGHT

Copyright (C) 2009 Simon Dawson.

=head1 AUTHOR

Simon Dawson E<lt>spdawson@gmail.comE<gt>

=head1 LICENSE

This file is part of Xylem.

   Xylem is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Xylem is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Xylem.  If not, see <http://www.gnu.org/licenses/>.

=cut
