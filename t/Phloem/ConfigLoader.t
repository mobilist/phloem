#!/usr/bin/perl -w
#
# Unit test script for Phloem::ConfigLoader.

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

use Test::More tests => 3; # qw(no_plan);

use Phloem::Logger;

BEGIN { use_ok('Phloem::ConfigLoader'); }

ok(Phloem::Logger->initialise(),
   'Initialising the Phloem logging subsystem.');

ok(my $node = Phloem::ConfigLoader::load(),
   'Loading node object from configuration file.');
