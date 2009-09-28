=head1 NAME

Phloem::ConfigPrinter

=head1 DESCRIPTION

A utility module for printing Phloem configuration settings.

=head1 SYNOPSIS

  use FileHandle;
  use Phloem::ConfigPrinter;
  my $node = Phloem::Node->new(...);
  my $fh = *STDOUT{IO};
  Phloem::ConfigPrinter::print($node,
                               $fh,
                               {'package_name' => 'Phloem',
                                'author'       => 'Lemuel Gulliver'});

=head1 METHODS

=over 8

=cut

package Phloem::ConfigPrinter;

use strict;
use warnings;
use diagnostics;

use Carp;
use FileHandle;
use POSIX qw(strftime);

use Phloem::Filter;
use Phloem::Node;
use Phloem::Role::Publish;
use Phloem::Role::Subscribe;
use Phloem::Root;
use Phloem::Rsync;

#------------------------------------------------------------------------------

=item print

Print the configuration data for the specified node object to the specified
filehandle.

A hash reference of metadata can optionally be specified, as the final
argument. This can include the 'package_name' and 'author' entries.

=cut

sub print
{
  my $node = shift or croak "No node specified.";
  croak "Expected a node object." unless $node->isa('Phloem::Node');

  my $fh = shift or croak "No filehandle specified.";
  croak "Expected a filehandle object." unless $fh->isa('FileHandle');

  my $args_hash = shift || {}; # Optional argument.
  croak "Expected a hash reference." unless (ref($args_hash) eq 'HASH');

  # See if we got any metadata.
  my $package_name = $args_hash->{'package_name'} // 'Phloem';
  my $author = $args_hash->{'author'} // 'Phloem';

  # More metadata.
  my $year = strftime("%Y", localtime);

  # Collect data.
  my $node_id = $node->id();
  my $node_group = $node->group() // '';
  my $node_is_root = $node->is_root() // 0;
  my $node_host = $node->host();
  my $node_register_frequency_s = $node->register_frequency_s();
  my $node_description = $node->description() // '';

  my $root_host = $node->root()->host();
  my $root_port = $node->root()->port();

  my $rsync_user = $node->rsync()->user();
  my $rsync_ssh_id_file = $node->rsync()->ssh_id_file();
  my $rsync_ssh_port = $node->rsync()->ssh_port();

  # Print the header.
  print $fh <<"xxx_END_HEADER";
<?xml version="1.0" encoding='UTF-8'?>
<!DOCTYPE node SYSTEM "node.dtd">

<!--

 Copyright (C) $year $author

 This file is part of $package_name.

    $package_name is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    $package_name is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with $package_name.  If not, see <http://www.gnu.org/licenses/>.

-->

<node id="$node_id" group="$node_group" is_root="$node_is_root"
  host="$node_host" register_frequency_s="$node_register_frequency_s">

  <description>
    $node_description
  </description>

  <root host="$root_host" port="$root_port" />

  <rsync user="$rsync_user"
    ssh_id_file="$rsync_ssh_id_file"
    ssh_port="$rsync_ssh_port" />
xxx_END_HEADER

  # Print details of the roles.
  my $roles_arrayref = $node->roles();
  foreach my $role (@$roles_arrayref) {
    my $role_type =
      $role->isa('Phloem::Role::Publish') ? 'publish' : 'subscribe';
    my $role_route = $role->route();
    my $role_directory = $role->directory();
    my $role_description = $role->description() // '';
    print $fh "  <role type=\"$role_type\" route=\"$role_route\" active=\"1\"";
    if ($role->isa('Phloem::Role::Publish')) {
      print $fh ">\n";
    } else {
      my $role_update_frequency_s = $role->update_frequency_s();
      print $fh " update_frequency_s=\"$role_update_frequency_s\">\n";
      my $filter = $role->filter();
      if ($filter) {
        my $filter_type = $filter->type();
        my $filter_value = $filter->value();
        my $filter_rule = $filter->rule();
        print $fh <<"xxx_END_ROLE_FILTER";
    <filter type="$filter_type" value="$filter_value" rule="$filter_rule" />
xxx_END_ROLE_FILTER
      }
    }

    print $fh <<"xxx_END_ROLE";
    <directory path="$role_directory" />
    <description>
      $role_description
    </description>
  </role>
xxx_END_ROLE
  }

  # Print the footer.
  print $fh <<"xxx_END_FOOTER";
</node>
xxx_END_FOOTER
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
