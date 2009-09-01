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

use Test::More tests => 12; # qw(no_plan);

BEGIN { use_ok('Xylem::Debug'); }

ok(!Xylem::Debug->enabled(), 'Debugging should be disabled initially.');
ok(Xylem::Debug->enabled(1), 'Debugging should be enabled.');
ok(Xylem::Debug->enabled(), 'Debugging should still be enabled.');
ok(!Xylem::Debug->enabled(0), 'Debugging should be disabled now.');
ok(!Xylem::Debug->enabled(), 'Debugging should still be disabled.');
ok(!Xylem::Debug->message('Hello teh World!'),
   'Printing a debug message (disabled).');
ok(Xylem::Debug->enabled(1), 'Debugging should be enabled again.');
my $message = 'Hello again teh World!';
ok(my $message2 = Xylem::Debug->message($message),
   'Printing a debug message (enabled).');
ok($message2 =~ /$message/, 'Messages should be similar.');
ok(my $message3 = Xylem::Debug->message(),
   'Should cope with an absent message.');
ok(length($message3), 'Returned message should be non-trivial.');
