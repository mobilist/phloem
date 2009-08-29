=head1 NAME

Xylem::TimeStamp

=head1 SYNOPSIS

  C<use Xylem::TimeStamp;>
  C<my $ts = Xylem::TimeStamp::create();>

=head1 METHODS

=over 8

=item create

Generate a time-stamp.

=back

=head1 DESCRIPTION

Time-stamp functionality for Xylem.

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

package Xylem::TimeStamp;

use strict;
use warnings;
use diagnostics;

use POSIX qw(strftime);

use lib qw(lib);

#------------------------------------------------------------------------------
sub create
# Generate a time-stamp.
{
  return strftime("%A %d %B %Y, %X %Z", localtime);
}

1;
