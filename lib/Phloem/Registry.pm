=head1 NAME

Phloem::Registry

=head1 SYNOPSIS

  C<use Phloem::Registry;>
  C<my $registry = Phloem::Registry->load();>

=head1 METHODS

=over 8

=item new

Constructor.

=item timestamp

Get the time-stamp.

=item nodes

Get a hash table of the nodes.

=item add_node

Add or update the specified node.

=item load

Load the saved registry from disk.

Returns a new object if no saved registry exists.

N.B. This is a class method.

=item save

Save the registry data to disk.

=back

=head1 DESCRIPTION

A registry of the nodes in a Phloem network.

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

package Phloem::Registry;

use strict;
use warnings;
use diagnostics;

use Fcntl qw(:flock); # Import LOCK_* constants.
use FileHandle;

use lib qw(lib);

use base qw(Xylem::Dumper);

use Phloem::Constants;
use Phloem::Node;
use Xylem::TimeStamp;

#------------------------------------------------------------------------------
sub new
# Constructor.
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
sub timestamp
# Get the time-stamp.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return $self->{'timestamp'};
}

#------------------------------------------------------------------------------
sub nodes
# Get a hash table of the nodes.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  return %{$self->{'nodes'}};
}

#------------------------------------------------------------------------------
sub add_node
# Add or update the specified node.
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
sub load
# Load the saved registry from disk.
#
# Returns a new object if no saved registry exists.
#
# N.B. This is a class method.
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  my $registry_file = $Phloem::Constants::REGISTRY_FILE;

  # Create and return a new object if there is no saved registry data.
  return $class->new() unless (-f $registry_file);

  my $registry_fh = FileHandle->new("< $registry_file")
    or die "Failed to open registry file for reading: $!";
  flock($registry_fh, LOCK_SH)
    or die "Failed to acquire shared file lock: $!";

  # Read the registry file.
  my $object_data = <$registry_fh>;

  flock($registry_fh, LOCK_UN) or die "Failed to unlock file: $!";
  $registry_fh->close() or die "Failed to close file: $!";

  # Attempt to reconstruct the object.
  my $self = eval " $object_data ";
  die "Failed to reconstruct object: $@" if $@;

  return $self;
}

#------------------------------------------------------------------------------
sub save
# Save the registry data to disk.
{
  my $self = shift or die "No object reference.";
  die "Unexpected object class." unless $self->isa(__PACKAGE__);

  my $registry_file = $Phloem::Constants::REGISTRY_FILE;
  my $registry_fh = FileHandle->new("> $registry_file")
    or die "Failed to open registry file for writing: $!";
  flock($registry_fh, LOCK_EX)
    or die "Failed to acquire exclusive file lock: $!";

  # Write to the registry file.
  print $registry_fh $self->data_dump();

  flock($registry_fh, LOCK_UN) or die "Failed to unlock file: $!";
  $registry_fh->close() or die "Failed to close file: $!";
}


1;
