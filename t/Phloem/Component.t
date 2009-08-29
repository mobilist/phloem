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

use Test::More tests => 8; # qw(no_plan);

use Phloem::Node;
use Phloem::Role;

BEGIN { use_ok('Phloem::Component'); }

ok(my $role = Phloem::Role->new('route'       => 'rootward',
                                'directory'   => 'some/path',
                                'description' => 'Dummy.'),
   'Creating role object.');
ok(my $node = Phloem::Node->new(), 'Creating node object.');
ok(my $component = Phloem::Component->new('node' => $node, 'role' => $role),
   'Creating component object.');
ok(my $node2 = $component->node(), 'Accessor for node.');
is_deeply($node2, $node, 'Nodes should match.');
ok(my $role2 = $component->role(), 'Accessor for role.');
is_deeply($role2, $role, 'Roles should match.');
