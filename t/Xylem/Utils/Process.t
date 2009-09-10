#!/usr/bin/perl -w
#
# Unit test script for Xylem::Utils::Process.

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

use Test::More tests => 2; # qw(no_plan);

BEGIN { use_ok('Xylem::Utils::Process'); }

diag('Spawning child process.');
my $child_pid = Xylem::Utils::Process::spawn_child();

unless ($child_pid) {
  diag('Exiting child process.');
  exit(0);
}

diag('We should still be running, after the child process exits.');
ok(1, 'Still running.');
