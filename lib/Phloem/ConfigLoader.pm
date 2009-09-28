=head1 NAME

Phloem::ConfigLoader

=head1 DESCRIPTION

A utility module for loading the Phloem configuration settings from file.

=head1 SYNOPSIS

  use Phloem::ConfigLoader;
  my $config = Phloem::ConfigLoader::load();

=head1 METHODS

=over 8

=cut

package Phloem::ConfigLoader;

use strict;
use warnings;
use diagnostics;

use Carp;
use File::Spec;

use Phloem::Constants;
use Phloem::Filter;
use Phloem::Logger;
use Phloem::Node;
use Phloem::Role::Publish;
use Phloem::Role::Subscribe;
use Phloem::Root;
use Phloem::Rsync;
use Xylem::Utils::XML;

#------------------------------------------------------------------------------

=item load

Load the configuration file.

Returns a node object.

=cut

sub load
{
  # Parse the configuration XML file.
  my $config_data = Xylem::Utils::XML::parse($Phloem::Constants::CONFIG_FILE);

  # Process the parsed XML data, returning a node object.
  return _node_from_xml_data($config_data);
}

#------------------------------------------------------------------------------
sub _node_from_xml_data
# Process the specified parsed XML data, returning a node object.
{
  my $xml_data = shift or croak "No XML data specified.";
  croak "Expected a hash reference." unless (ref($xml_data) eq 'HASH');

  # Get the root for the node.
  my $root_object = _root_from_xml_data($xml_data);

  # Get the rsync for the node.
  my $rsync_object = _rsync_from_xml_data($xml_data);

  # Create a node object.
  my $node_id = $xml_data->{'id'} or croak "No node ID.";
  my $node_group = $xml_data->{'group'} // '';
  my $node_description = $xml_data->{'description'}->[0] // '';
  my $node_is_root = $xml_data->{'is_root'} // 0;
  my $node_register_frequency_s =
    $xml_data->{'register_frequency_s'} //
    $Phloem::Constants::DEFAULT_NODE_REGISTER_FREQUENCY_S;
  my $node_host = $xml_data->{'host'} // 'localhost';
  my $node_object =
    Phloem::Node->new('id'                   => $node_id,
                      'group'                => $node_group,
                      'description'          => $node_description,
                      'is_root'              => $node_is_root,
                      'register_frequency_s' => $node_register_frequency_s,
                      'host'                 => $node_host,
                      'root'                 => $root_object,
                      'rsync'                => $rsync_object)
    or croak "Failed to create node object.";

  # Add roles to the node.
  my $roles = $xml_data->{'role'};
 ROLE:
  foreach my $current_role (@$roles) {
    my $role_type = $current_role->{'type'} or croak "No role type.";
    my $role_route = $current_role->{'route'} or croak "No role route.";
    my $role_active = $current_role->{'active'} // 1;
    my $role_directory = $current_role->{'directory'} or croak "No directory.";
    my $role_directory_path =
      $role_directory->[0]->{'path'} or croak "No directory path.";
    my $role_description = $current_role->{'description'}->[0] // '';

    # Convert the directory path to an absolute path.
    my $role_directory_path_abs = File::Spec->rel2abs($role_directory_path);

    unless ($role_active) {
      Phloem::Logger->append(
        "Role to $role_type on $role_route route is disabled.");
      next ROLE;
    }

    # Create a role object.
    my %role_options = ('route'       => $role_route,
                        'directory'   => $role_directory_path_abs,
                        'description' => $role_description);
    my $role_object;
    if ($role_type eq 'publish') {
      $role_object = Phloem::Role::Publish->new(%role_options);
    } else {
      my $role_filter = $current_role->{'filter'};
      if ($role_filter) {
        my $role_filter_type = $role_filter->[0]->{'type'}
          or croak "No filter type.";
        my $role_filter_value = $role_filter->[0]->{'value'}
          or croak "No filter value.";
        my $role_filter_rule = $role_filter->[0]->{'rule'} // 'exact';
        my $filter = Phloem::Filter->new('type'  => $role_filter_type,
                                         'value' => $role_filter_value,
                                         'rule'  => $role_filter_rule)
          or croak "Failed to create filter object.";
        $role_options{'filter'} = $filter;
      }

      {
        my $role_update_frequency_s =
          $current_role->{'update_frequency_s'} //
          $Phloem::Constants::DEFAULT_SUBSCRIBER_UPDATE_FREQUENCY_S;
        $role_options{'update_frequency_s'} = $role_update_frequency_s;
      }

      $role_object = Phloem::Role::Subscribe->new(%role_options);
    }
    croak "Failed to create role object." unless $role_object;

    # Add the role to the node.
    $node_object->add_role($role_object);
  }

  return $node_object;
}

#------------------------------------------------------------------------------
sub _root_from_xml_data
# Process the specified parsed XML data, returning a root object.
{
  my $xml_data = shift or croak "No XML data specified.";
  croak "Expected a hash reference." unless (ref($xml_data) eq 'HASH');

  my $root_object;
  {
    my $node_root = $xml_data->{'root'} or croak "No root.";
    {
      my $node_root_host = $node_root->[0]->{'host'} or croak "No root host.";
      my $node_root_port = $node_root->[0]->{'port'} or croak "No root port.";
      $root_object = Phloem::Root->new('host' => $node_root_host,
                                       'port' => $node_root_port)
        or croak "Failed to create root object.";
    }
  }

  return $root_object;
}

#------------------------------------------------------------------------------
sub _rsync_from_xml_data
# Process the specified parsed XML data, returning a rsync object.
{
  my $xml_data = shift or croak "No XML data specified.";
  croak "Expected a hash reference." unless (ref($xml_data) eq 'HASH');

  my $rsync_object;
  {
    my $node_rsync = $xml_data->{'rsync'} or croak "No rsync.";
    {
      my $node_rsync_user = $node_rsync->[0]->{'user'}
        or croak "No rsync user.";
      my $node_rsync_ssh_id_file =
        $node_rsync->[0]->{'ssh_id_file'} or croak "No SSH identity file.";

      # Convert the SSH identity file path to an absolute path.
      my $node_rsync_ssh_id_file_abs =
        File::Spec->rel2abs($node_rsync_ssh_id_file);

      my $node_ssh_port = $node_rsync->[0]->{'ssh_port'} // 22;

      $rsync_object =
        Phloem::Rsync->new('user'        => $node_rsync_user,
                           'ssh_id_file' => $node_rsync_ssh_id_file_abs,
                           'ssh_port'    => $node_ssh_port)
        or croak "Failed to create rsync object.";
    }
  }

  return $rsync_object;
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
