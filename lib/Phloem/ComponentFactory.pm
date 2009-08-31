=head1 NAME

Phloem::ComponentFactory

=head1 DESCRIPTION

A factory for Phloem components.

=head1 SYNOPSIS

  C<use Phloem::ComponentFactory;>
  C<use Phloem::Role::Publish;>
  C<my $role = Phloem::Role::Publish->new(...);>
  C<my $component = Phloem::ComponentFactory->create($role);>

=head1 METHODS

=over 8

=cut

package Phloem::ComponentFactory;

use strict;
use warnings;
use diagnostics;

use lib qw(lib);
use Phloem::Node;
use Phloem::Role;
use Phloem::Component::Publisher;
use Phloem::Component::Subscriber;

#------------------------------------------------------------------------------

=item create

Factory method.

=cut

sub create
{
  my $node = shift or die "No node specified.";
  die "Expected a node object." unless $node->isa('Phloem::Node');

  my $role = shift or die "No role specified.";
  die "Expected a role object." unless $role->isa('Phloem::Role');

  return Phloem::Component::Publisher->new('node' => $node, 'role' => $role)
    if $role->isa('Phloem::Role::Publish');

  return Phloem::Component::Subscriber->new('node' => $node, 'role' => $role);
}

1;

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
