=head1 NAME

Phloem::Logger

=head1 SYNOPSIS

  C<use Phloem::Logger;>
  C<Phloem::Logger->clear();>
  C<Phloem::Logger->append('Hello teh world!');>

=head1 METHODS

=over 8

=item append

Append the specified message to the log file.

=item clear

Clear the log file.

=back

=head1 DESCRIPTION

Logging utilities for Phloem.

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

package Phloem::Logger;

use strict;
use warnings;
use diagnostics;

use lib qw(lib);
use Phloem::Constants;
use Xylem::Logger;

#------------------------------------------------------------------------------
sub append
# Append the specified message to the log file.
{
  Xylem::Logger::append(@_, $Phloem::Constants::LOG_FILE);
}

#------------------------------------------------------------------------------
sub clear
# Clear the log file.
{
  Xylem::Logger::clear($Phloem::Constants::LOG_FILE);
}

1;
