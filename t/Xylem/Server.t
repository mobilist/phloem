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

use IO::Socket::INET;
use Test::More tests => 6; # qw(no_plan);

use constant TEST_PORT => 9999;
use constant TEST_MESSAGE => "Hello teh World!\r\n";;

BEGIN { use_ok('Xylem::Server'); }

package DummyServer;

use base qw(Xylem::Server);

sub process_request {
  my $class = shift or die "No class.";
  my $sock = shift or die "No socket.";
  print $sock main::TEST_MESSAGE;
  # Exit the (child) process.
  exit(0);
}

package main;

ok(my $child_pid = DummyServer->run(TEST_PORT), 'Running server.');

ok(my $sock = IO::Socket::INET->new('PeerAddr' => 'localhost',
                                    'PeerPort' => TEST_PORT,
                                    'Proto'    => 'tcp',
                                    'Type'     => SOCK_STREAM),
   'Connecting to the server.');

ok(my $data = <$sock>, 'Reading data from the server.');
is($data, TEST_MESSAGE, 'Server sent correct data.');
ok(1, 'Still running, after the server has shut down.');
