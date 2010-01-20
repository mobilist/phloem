=head1 NAME

Phloem::Role::Subscribe

=head1 DESCRIPTION

A subscribe role for a node in a Phloem network.

=head1 SYNOPSIS

  use Phloem::Constants qw(:routes);
  use Phloem::Role::Subscribe;
  my $filter = Phloem::Filter->new('type'  => 'group',
                                   'value' => '^ova\d+',
                                   'rule'  => 'match');
  my $role =
    Phloem::Role::Subscribe->new('route'       => LEAF2ROOT,
                                 'directory'   => 'some/dir/path',
                                 'description' => 'Some sort of role.',
                                 'filter'      => $filter);

  # Set the update frequency, in seconds.
  $role->update_frequency_s(60);

=head1 METHODS

=over 8

=item new

Constructor.

=item filter

Get/set the filter.

=item update_frequency_s

Get/set the update frequency, in seconds.

=cut

package Phloem::Role::Subscribe;

use strict;
use warnings;
use diagnostics;

use Carp;

use Phloem::Filter;
use Phloem::Role;

use Xylem::Class ('base'   => 'Phloem::Role',
                  'fields' => {'filter'             => 'Phloem::Filter',
                               'update_frequency_s' => '$'});

1;

=back

=head1 SEE ALSO

L<Phloem::Role>, L<Phloem::Role::Publish>, L<Phloem::Filter>

=head1 COPYRIGHT

Copyright (C) 2009-2010 Simon Dawson.

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
