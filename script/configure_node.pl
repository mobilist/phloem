#!/usr/bin/perl -w

=head1 NAME

configure_node.pl

=head1 DESCRIPTION

Generate node configuration information using user input.

=head1 SYNOPSIS

configure_node.pl [options]

=head1 OPTIONS

=over 8

=item B<-h, --help>

Print usage information, and then exit.

=item B<-m, --man>

Print this manual page, and then exit.

=item B<-l, --license>

Print the license terms, and then exit.

=item B<-o, --output-file>

Specify a file path to output the configuration information to. If no file
path is specified, then configuration information is sent to standard output.

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

use strict;
use warnings;
use diagnostics;

use FileHandle;
use Term::UI;
use Term::ReadLine;

use lib qw(lib);
use Phloem::ConfigPrinter;
use Phloem::Constants qw(:routes);
use Phloem::Node;
use Phloem::Role::Publish;
use Phloem::Role::Subscribe;
use Phloem::Root;
use Phloem::Rsync;
use Xylem::Utils::Code;

#==============================================================================
# Start of main program.
{
  my $opt_o;
  Xylem::Utils::Code::process_command_line('o|output-file=s' => \$opt_o);

  # Metadata.
  my $package_name = 'Phloem';
  my $author = 'Simon Dawson';

  my $node = _construct_node($package_name);

  # Get a filehandle for output.
  my $fh = $opt_o ? FileHandle->new("> $opt_o") : *STDOUT{IO};
  die "Failed to open output filehandle: $!" unless $fh;
  die "Expected a FileHandle object." unless $fh->isa('FileHandle');

  Phloem::ConfigPrinter::print($node,
                               $fh,
                               {'package_name' => $package_name,
                                'author'       => $author});
}
# End of main program; subroutines follow.


#------------------------------------------------------------------------------
sub _construct_node
# Construct a node object, using user input.
{
  my $package_name = shift;

  my $term = Term::ReadLine->new($package_name);

  my $node = Phloem::Node->new();

  $node->id($term->readline('Node ID: '));
  $node->group($term->readline('Node group name: '));
  $node->is_root($term->ask_yn('prompt'  => 'Is this the root node?',
                               'default' => 'n'));
  $node->host($term->readline('Node host/IP: '));
  $node->register_frequency_s(
    $term->get_reply('prompt' => 'Node registration frequency (seconds): ',
                     'allow'  => sub { return $_[0] =~ /\d+/o; }));
  $node->description($term->readline('Brief description of the node: '));

  my $root = Phloem::Root->new();
  $root->host(
    $node->is_root() ? $node->host() : $term->readline('Root node host/IP: '));
  $root->port($term->readline('Root node port number: '));
  $node->root($root);

  my $rsync = Phloem::Rsync->new();
  $rsync->user($term->readline('User name for ssh/rsync: '));
  $rsync->ssh_id_file($term->readline('Path to the SSH identity file: '));
  $rsync->ssh_port($term->readline('Port number for SSH: ') // 22);
  $node->rsync($rsync);

  my $role_counter = {};
  while ($term->ask_yn('prompt' => 'Add a role?', 'default' => 'y')) {

    my $role_type = $term->get_reply('prompt'  => 'What type of role is this?',
                                     'choices' => [qw(publish subscribe)],
                                     'default' => 'publish');

    my $role;
    if ($role_type eq 'publish') {
      $role = Phloem::Role::Publish->new();
    } else {
      $role = Phloem::Role::Subscribe->new();
    }
    $role_counter->{$role_type}++;
    if ($role_counter->{$role_type} > 2) {
      print STDERR
        "ERROR: Cannot have more than two (2) roles of each type.\n";
      exit(1);
    }

    $role->route(
      $term->get_reply('prompt'  => 'What route is the role for?',
                       'choices' => [ROOT2LEAF, LEAF2ROOT],
                       'default' => ROOT2LEAF));
    $role->directory($term->readline('Directory path for the role: '));
    $role->description($term->readline('Brief description of the role: '));

    if ($role->isa('Phloem::Node::Subscribe')) {
      $role->update_frequency_s(
        $term->get_reply('prompt' => 'Role update frequency (seconds): ',
                         'allow'  => sub { return $_[0] =~ /\d+/o; }));
      if ($term->ask_yn('prompt'  => 'Add a filter for the role?',
                        'default' => 'n')) {
        my $filter = Phloem::Filter->new();
        $filter->type(
          $term->get_reply('prompt'  => 'What type of filter is this?',
                           'choices' => [qw(node group)],
                           'default' => 'node'));
        $filter->value($term->readline('Filter value: '));
        $filter->rule($term->get_reply('prompt'  => 'Filter rule: ',
                                       'choices' => [qw(exact match)],
                                       'default' => 'exact'));
        $role->filter($filter);
      }
    }

    $node->add_role($role);
  }

  return $node;
}
