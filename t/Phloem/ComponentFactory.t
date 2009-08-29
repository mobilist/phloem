#!/usr/bin/perl -w
#
#D Unit test script.

# Copyright (C) 2009 Simon Dawson
#
# This file is part of Phloem.
#
#    Phloem is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Phloem is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Phloem.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use diagnostics;

use Test::More tests => 10; # qw(no_plan);

use Phloem::Node;
use Phloem::Role::Publish;
use Phloem::Root;

BEGIN { use_ok('Phloem::ComponentFactory'); }

ok(my $root = Phloem::Root->new('host' => 'egg', 'port' => 1234),
   'Creating root object.');
my %object_data = ('id'          => 'egg',
                   'group'       => 'ova',
                   'is_root'     => 1,
                   'host'        => 'egg',
                   'description' => 'This is the egg.',
                   'root'        => $root);

ok(my $node = Phloem::Node->new(%object_data), 'Creating node object.');
ok(my $role = Phloem::Role::Publish->new('route'       => 'rootward',
                                         'directory'   => 'some/path',
                                         'description' => 'A dummy role.'),
   'Creating publish role object.');

ok($node->add_role($role), 'Adding role to node.');

ok(my $component = Phloem::ComponentFactory::create($node, $role),
   'Creating component using factory.');
ok(my $node2 = $component->node(), 'Getting node from component.');
ok(my $role2 = $component->role(), 'Getting role from component.');
is_deeply($node2, $node, 'Nodes should match.');
is_deeply($role2, $role, 'Roles should match.');
