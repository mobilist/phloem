#!/usr/bin/perl -w
#
#D Unit test script.

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

use Test::More tests => 4; # qw(no_plan);

BEGIN { use_ok('Xylem::TimeStamp'); }

ok(my $ts1 = Xylem::TimeStamp::create(), 'Generating a time-stamp.');

diag('Waiting for a second, so that the next time-stamp is different...');
sleep(1);
ok(my $ts2 = Xylem::TimeStamp::create(), 'Generating another time-stamp.');
ok($ts2 ne $ts1, 'Time-stamps should differ.');
