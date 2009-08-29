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

use Phloem::Role;
use Phloem::Root;

BEGIN { use_ok('Phloem::Component'); }

ok(my $role = Phloem::Role->new('route'       => 'rootward',
                                'directory'   => 'some/path',
                                'description' => 'Dummy.'),
   'Creating role object.');
ok(my $root = Phloem::Root->new('host' => 'egg12345',
                                'port' => 1234),
   'Creating root object.');
ok(my $component = Phloem::Component->new('role' => $role, 'root' => $root),
   'Creating component object.');
ok(my $role2 = $component->role(), 'Accessor for role.');
is_deeply($role2, $role, 'Roles should match.');
ok(my $root2 = $component->root(), 'Accessor for root.');
is_deeply($root2, $root, 'Roots should match.');
