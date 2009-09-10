#!/usr/bin/perl -w
#
# Unit test script for Xylem::Dumper::Text.

# Copyright (C) 2009 Simon Dawson
#
# This file is part of Xylem.
#
#    Xylem is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Xylem is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Xylem.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use diagnostics;

use Test::More tests => 7; # qw(no_plan);

BEGIN { use_ok('Xylem::Dumper::Text'); }

package Dummy;

use base qw(Xylem::Dumper::Text);

sub new { return bless({'shoe' => 'horse'}, __PACKAGE__); };

package main;

ok(my $dummy = Dummy->new(), 'Create dummy subclass object.');
ok(my $data = $dummy->data_dump(), 'Dumping data.');
diag($data);
ok(my $dummy2 = Dummy->data_load($data),
   'Recreating object from dumped data.');
is_deeply($dummy2, $dummy, 'Objects should be identical.');
ok(my $data2 = $dummy2->data_dump(), 'Dumping data again.');
diag($data2);
is($data2, $data, 'Dumped data should be identical.');
