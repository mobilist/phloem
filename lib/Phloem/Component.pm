=head1 NAME

Phloem::Component

=head1 DESCRIPTION

An abstract base class for Phloem components.

=head1 SYNOPSIS

  C<use Phloem::Component;>

=head1 METHODS

=over 8

=item new

Constructor.

=item node

Get the node.

=item role

Get the role.

=cut

package Phloem::Component;

use strict;
use warnings;
use diagnostics;

use Class::Struct 'Phloem::Component' => {'node' => 'Phloem::Node',
                                          'role' => 'Phloem::Role'};

use lib qw(lib);
use Phloem::Logger;
use Phloem::Node;
use Phloem::Role;

#------------------------------------------------------------------------------

=item run

Run the component.

=cut

sub run
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  $self->_do_run();
}

#------------------------------------------------------------------------------
sub _do_run
# Run the component --- "protected" method.
{
  die "PURE VIRTUAL BASE CLASS METHOD! MUST BE OVERRIDDEN!";
}

1;

=back

=head1 SEE ALSO

L<Phloem::Component::Publisher>, L<Phloem::Component::Subscriber>

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
