#!/usr/bin/perl -w
#
# Unit test script for Phloem::Filter.

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

use Test::More tests => 9; # qw(no_plan);

use Phloem::Node;

BEGIN { use_ok('Phloem::Filter'); }

my %object_data = ('type'  => 'group',
                   'value' => '^ova\d+',
                   'rule'  => 'match');

ok(my $filter = Phloem::Filter->new(%object_data), 'Creating filter object.');

ok($filter->type() eq $object_data{'type'}, 'Accessor for type.');
ok($filter->value() eq $object_data{'value'}, 'Accessor for value.');
ok($filter->rule() eq $object_data{'rule'}, 'Accessor for rule.');
ok(my $node = Phloem::Node->new('id'    => 'egg',
                                'group' => 'ova1'), 'Creating node object.');
ok($filter->apply($node), 'Filter should match node.');
ok($filter->type('node'), 'Modifying filter.');
ok(!$filter->apply($node), 'Filter should not match node.');
