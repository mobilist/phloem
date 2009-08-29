=head1 NAME

Phloem::ComponentFactory

=head1 SYNOPSIS

  C<use Phloem::ComponentFactory;>
  C<use Phloem::Role::Publish;>
  C<my $role = Phloem::Role::Publish->new(...);>
  C<my $component = Phloem::ComponentFactory->create($role);>

=head1 METHODS

=over 8

=item create

Factory method.

=back

=head1 DESCRIPTION

A factory for Phloem components.

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

package Phloem::ComponentFactory;

use strict;
use warnings;
use diagnostics;

use lib qw(lib);
use Phloem::Role;
use Phloem::Root;
use Phloem::Component::Publisher;
use Phloem::Component::Subscriber;

#------------------------------------------------------------------------------
sub create
# Factory method.
{
  my $role = shift or die "No role specified.";
  die "Expected a role object." unless $role->isa('Phloem::Role');

  my $root = shift or die "No root specified.";
  die "Expected a root object." unless $root->isa('Phloem::Root');

  return Phloem::Component::Publisher->new('role' => $role, 'root' => $root)
    if $role->isa('Phloem::Role::Publish');

  return Phloem::Component::Subscriber->new('role' => $role, 'root' => $root);
}

1;
