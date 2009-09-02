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

use Test::More tests => 5; # qw(no_plan);

BEGIN { use_ok('Phloem::Role'); }

my %object_data = ('route'       => 'leaf2root',
                   'directory'   => 'some/dir/path',
                   'description' => 'Dummy role.');

ok(my $role = Phloem::Role->new(%object_data), 'Creating role object.');

ok($role->route() eq $object_data{'route'}, 'Accessor for route.');
ok($role->directory() eq $object_data{'directory'}, 'Accessor for directory.');
ok($role->description() eq $object_data{'description'},
   'Accessor for description.');
