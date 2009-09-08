=head1 NAME

Phloem::Root

=head1 DESCRIPTION

Root node information for Phloem.

=head1 SYNOPSIS

  use Phloem::Root;

=head1 METHODS

=over 8

=item new

Constructor.

=item host

Get the host.

=item port

Get the port.

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

package Phloem::Root;

use strict;
use warnings;
use diagnostics;

use Class::Struct 'Phloem::Root' => {'host' => '$',
                                     'port' => '$'};

use lib qw(lib);

1;
