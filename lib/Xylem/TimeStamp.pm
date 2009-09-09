=head1 NAME

Xylem::TimeStamp

=head1 DESCRIPTION

Time-stamp functionality for Xylem.

=head1 SYNOPSIS

  use Xylem::TimeStamp;
  my $ts = Xylem::TimeStamp::create();

=head1 METHODS

=over 8

=cut

package Xylem::TimeStamp;

use strict;
use warnings;
use diagnostics;

use POSIX qw(strftime);

#------------------------------------------------------------------------------

=item create

Generate a time-stamp.

=cut

sub create
{
  return strftime("%A %d %B %Y, %X %Z", localtime);
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
