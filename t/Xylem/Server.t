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

use Test::More tests => 3; # qw(no_plan);

BEGIN { use_ok('Xylem::Server'); }

package Dummy;

use base qw(Xylem::Server);

sub process_request {
  my $class = shift or die "No class.";
  my $sock = shift or die "No socket.";
  print $sock "Hello teh World!\r\n";
  # Exit the (child) process.
  exit(0);
}

package main;

use constant TEST_PORT => 9999;

ok(my $child_pid = Dummy->run(TEST_PORT), 'Running server.');

diag('We should still be running, after the server shuts down.');
ok(1, 'Still running.');
