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

use Test::More tests => 4; # qw(no_plan);

BEGIN { use_ok('Phloem::Root'); }

my %object_data = ('host' => 'egg',
                   'port' => 1234);

ok(my $root = Phloem::Root->new(%object_data), 'Creating root object.');

ok($root->host() eq $object_data{'host'}, 'Accessor for host.');
ok($root->port() eq $object_data{'port'}, 'Accessor for port.');
