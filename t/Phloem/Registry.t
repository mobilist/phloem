#!/usr/bin/perl -w
#
# Unit test script for Phloem::Registry.

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

use Test::More tests => 14; # qw(no_plan);

use Xylem::TimeStamp;
use Phloem::Node;

BEGIN { use_ok('Phloem::Registry'); }

my %nodes;
my %object_data = ('timestamp' => Xylem::TimeStamp::create(),
                   'nodes'     => \%nodes);

ok(my $registry = Phloem::Registry->new(%object_data),
   'Creating registry object.');

is_deeply($registry, \%object_data, 'Internal object data.');
ok($registry->timestamp() eq $object_data{'timestamp'},
   'Accessor for timestamp.');
ok($registry->nodes() == 0, 'Accessor for nodes.');

ok(my $node = Phloem::Node->new('id' => 'egg', 'root' => 'dog'),
   'Creating node object.');

ok($registry->add_node($node), 'Adding node to registry.');
ok(keys(%nodes) == 1, 'Number of nodes in registry.');
ok(my $node2 = Phloem::Node->new('id' => 'cheese', 'root' => 'dog'),
   'Creating node object.');

ok($registry->add_node($node2), 'Adding node to registry.');
ok(keys(%nodes) == 2, 'Number of nodes in registry.');

ok($registry->save(), 'Saving registry data.');
ok(my $r2 = Phloem::Registry->load(), 'Loading registry data.');
is_deeply($r2, $registry, 'Round-trip object data.');
