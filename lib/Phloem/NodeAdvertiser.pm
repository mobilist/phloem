=head1 NAME

Phloem::NodeAdvertiser

=head1 DESCRIPTION

An object to handle the registration of a node with the "root" node.

=head1 SYNOPSIS

  use Phloem::Node;
  use Phloem::NodeAdvertiser;

  my $node = Phloem::Node->new('id' => 'egg', 'group' => 'ova1');
  my $node_advertiser = Phloem::NodeAdvertiser->new('node' => $node)
    or die "Failed to create node advertiser.";

  $node_advertiser->run();

=head1 METHODS

=over 8

=item new

Constructor.

=item node

Get the node.

=cut

package Phloem::NodeAdvertiser;

use strict;
use warnings;
use diagnostics;

use Carp;

use Xylem::Class ('fields' => {'node' => 'Phloem::Node'});

use Phloem::Logger;
use Phloem::RegistryClient;

#------------------------------------------------------------------------------

=item run

Run the advertiser.

=cut

sub run
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  # If the node is not a publisher, then we may as well shut down right now.
  unless ($self->node()->is_publisher()) {
    Phloem::Logger->append('Node advertiser ending: node does not publish.');
    return;
  }

  # Get the update frequency (in seconds) for the node.
  my $node_register_frequency_s = $self->node()->register_frequency_s();

  # Sit in a loop, periodically registering our node with the "root" node.
  while (1) {
    Phloem::Logger->append('Registering this node with the root.');
    if ($self->_register_node()) {
      # If we are handling the root node, then we can shut down as soon as
      # we've registered it.
      if ($self->node()->is_root()) {
        Phloem::Logger->append('Node advertiser ending: registered root.');
        return;
      }
    } else {
      Phloem::Logger->append('Failed to register node.');
    }
  } continue {
    sleep($node_register_frequency_s);
  }
}

#------------------------------------------------------------------------------
sub _register_node
# Register out node with the "root" node.
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  return Phloem::RegistryClient::register_node($self->node());
}

1;

=back

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
