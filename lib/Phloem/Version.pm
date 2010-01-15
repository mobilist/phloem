=head1 NAME

Phloem::Version

=head1 DESCRIPTION

No code, just the Phloem version number.

=head1 SYNOPSIS

  use Phloem::Version;
  my $phloem_version = $Phloem::Version::VERSION;
  print "This is Phloem, version $phloem_version.\n";

=cut

package Phloem::Version;

use strict;
use warnings;
use diagnostics;

use Carp;

use version; our $VERSION = qv('0.0.8');

1;

=head1 SEE ALSO

L<Phloem::Manual>

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
