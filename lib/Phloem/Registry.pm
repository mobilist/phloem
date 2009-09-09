=head1 NAME

Phloem::Registry

=head1 DESCRIPTION

A registry of the nodes in a Phloem network.

=head1 SYNOPSIS

  use Phloem::Registry;
  my $registry = Phloem::Registry->load();

=head1 METHODS

=over 8

=cut

package Phloem::Registry;

use strict;
use warnings;
use diagnostics;

use File::Temp;

use lib qw(lib);

use base qw(Xylem::Dumper);

use Phloem::Debug;
use Phloem::Node;
use Xylem::TimeStamp;
use Xylem::Utils::File;

#------------------------------------------------------------------------------

=item new

Constructor.

=cut

sub new
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $self = {'timestamp' => Xylem::TimeStamp::create(),
              'nodes'     => {},
              @_};
  return bless($self, $class);
}

#------------------------------------------------------------------------------

=item timestamp

Get the time-stamp.

=cut

sub timestamp
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->{'timestamp'};
}

#------------------------------------------------------------------------------

=item nodes

Get a hash table of the nodes.

=cut

sub nodes
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return %{$self->{'nodes'}};
}

#------------------------------------------------------------------------------

=item add_node

Add or update the specified node.

=cut

sub add_node
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $node = shift or die "No node specified.";
  die "Expected a node object." unless $node->isa('Phloem::Node');

  # Add the node.
  my $node_id = $node->id();
  $self->{'nodes'}->{$node_id} = $node;

  # Update our time-stamp.
  $self->{'timestamp'} = Xylem::TimeStamp::create();
}

#------------------------------------------------------------------------------

=item load

Load the saved registry from disk.

Returns a new object if no saved registry exists.

N.B. This is a class method.

=cut

sub load
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $registry_file = _registry_file();

  # Create and return a new object if there is no saved registry data.
  return $class->new() unless (-f $registry_file);

  # Read the registry file.
  Phloem::Debug->message(
    "Loading registry from $registry_file");
  my $object_data = Xylem::Utils::File::read($registry_file);

  # Create and return a new object if there is no saved registry data.
  return $class->new() unless $object_data;

  # Attempt to reconstruct the object.
  my $self = $class->data_load($object_data)
    or die "Failed to reconstruct object.";

  return $self;
}

#------------------------------------------------------------------------------

=item save

Save the registry data to disk.

=cut

sub save
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $registry_file = _registry_file();

  # Write to the registry file.
  Phloem::Debug->message(
    "Saving registry to $registry_file");
  Xylem::Utils::File::write($registry_file, $self->data_dump());
}

#------------------------------------------------------------------------------
my $_registry_file; # A "private" module variable.
sub _registry_file
# Get the path to the registry file.
{
  unless ($_registry_file) {
    my $temp_fh = File::Temp->new('UNLINK' => 0);
    $_registry_file = $temp_fh->filename();
  }

  return $_registry_file;
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
