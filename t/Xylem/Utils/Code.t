#!/usr/bin/perl -w
#
# Unit test script for Xylem::Utils::Code.

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

use English;

use Test::More tests => 5; # qw(no_plan);

BEGIN { use_ok('Xylem::Utils::Code'); }

diag('Checking the code of the currently-running test.');
ok(Xylem::Utils::Code::check_code_file($PROGRAM_NAME), 'Code should be okay.');
ok(my %deps = Xylem::Utils::Code::get_dependencies($PROGRAM_NAME),
   'Getting dependencies of the currently-running test.');
ok(exists($deps{'Test::More'}), 'Should depend on Test::More.');
ok(!exists($deps{'Egg::Farmer'}), 'Should not depend on Egg::Farmer.');
