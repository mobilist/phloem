=head1 NAME

Phloem::Role

=head1 DESCRIPTION

Base class for a role for a node in a Phloem network.

=head1 SYNOPSIS

  use Phloem::Constants qw(:routes);
  use Phloem::Role;
  my $role = Phloem::Role->new('route'       => LEAF2ROOT,
                               'directory'   => 'some/dir/path',
                               'description' => 'Some sort of role.');

  # Change the route.
  $role->route(LEAF2ROOT);

  print $role->description(), "\n";

=head1 METHODS

=over 8

=item new

Constructor.

=item route

Get/set the route.

=item directory

Get/set the directory.

=item description

Get/set the description.

=cut

package Phloem::Role;

use strict;
use warnings;
use diagnostics;

use Carp;

use Xylem::Class ('package' => 'Phloem::Role',
                  'fields'  => {'route'       => '$',
                                'directory'   => '$',
                                'description' => '$'});

1;

=back

=head1 SEE ALSO

L<Phloem::Role::Publish>, L<Phloem::Role::Subscribe>

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
