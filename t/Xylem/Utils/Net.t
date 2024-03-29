#!/usr/bin/perl -w
#
# Unit test script for Xylem::Utils::Net.

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

use Test::More tests => 5; # qw(no_plan);

use constant TEST_PORT => 9999;

BEGIN { use_ok('Xylem::Utils::Net'); }

is(Xylem::Utils::Net::ping('localhost'), 1, 'Should be able to ping ourself.');

diag('Waiting for a ping to time-out...');
ok(!Xylem::Utils::Net::ping('donkey.sputem.stick'),
   'Should not be able to ping a non-existent host.');
ok(my $server_sock = Xylem::Utils::Net::get_server_tcp_socket(TEST_PORT),
   'Creating client TCP socket.');
ok(my $client_sock = Xylem::Utils::Net::get_client_tcp_socket('localhost',
                                                              TEST_PORT),
   'Creating client TCP socket.');
