#!/usr/bin/perl -w
#
# Unit test script for Xylem::Rsync::Stats.

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

use Test::More tests => 6; # qw(no_plan);

BEGIN { use_ok('Xylem::Rsync::Stats'); }

ok(my $transfer_stats =
   Xylem::Rsync::Stats->new('num_files'             => 3,
                            'num_files_transferred' => 2,
                            'total_bytes_sent'      => 48),
   'Creating transfer stats object.');
ok($transfer_stats->transfer_rate(1.234), 'Setting transfer rate.');
is($transfer_stats->transfer_rate(), 1.234, 'Getting transfer rate.');
ok(!$transfer_stats->total_bytes_received(),
   'Getting total number of bytes received.');
is($transfer_stats->num_files(), 3, 'Getting number of files.');
