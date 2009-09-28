=head1 NAME

Phloem::Filter

=head1 DESCRIPTION

A node filter for Phloem.

=head1 SYNOPSIS

  use Phloem::Filter;
  my $filter = Phloem::Filter->new('type'  => 'group',
                                   'value' => '^ova\d+',
                                   'rule'  => 'match');
  my $node = Phloem::Node->new('id' => 'egg', 'group' => 'ova1');
  $filter->apply($node) or die "Filter should match node.";

=head1 METHODS

=over 8

=item new

Constructor.

=item type

Get the type.

=item value

Get the value.

=item rule

Get the rule.

=cut

package Phloem::Filter;

use strict;
use warnings;
use diagnostics;

use Carp;

use Xylem::Class ('class'  => 'Phloem::Filter',
                  'fields' => {'type'  => '$',
                               'value' => '$',
                               'rule'  => '$'});

use Phloem::Node;

#------------------------------------------------------------------------------

=item apply

Apply the filter to the specified node.

Returns true if the node "matches", or false otherwise.

=cut

sub apply
{
  my $self = shift or croak "No object reference.";
  croak "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $node = shift or croak "No node specified.";
  croak "Expected a node object." unless $node->isa('Phloem::Node');

  # Get the data to be tested. (This depend upon what type of filter this is.)
  my $data_to_test;
  {
    my $filter_type = $self->type() or croak "No filter type set.";
    if ($filter_type eq 'node') {
      $data_to_test = $node->id();
    } elsif ($filter_type eq 'group') {
      $data_to_test = $node->group();
    } else {
      croak "Unsupported filter type.";
    }
  }
  croak "No data to test." unless $data_to_test;

  # Do the filtering.
  my $filter_value = $self->value() or croak "No filter value set.";
  my $filter_rule = $self->rule() or croak "No filter rule set.";
  if ($filter_rule eq 'match') {
    # Sanity-check the regular expression.
    eval {
      '' =~ /$filter_value/;
    };
    croak "Invalid filter regular expression: $@" if $@;
    return ($data_to_test =~ /$filter_value/) ? 1 : 0;
  } elsif ($filter_rule eq 'exact') {
    return ($data_to_test eq $filter_value) ? 1 : 0;
  } else {
    croak "Unsupported filter rule.";
  }

  croak "Hmm. Should have returned by now.";
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
