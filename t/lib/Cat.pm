# Unit test module for Xylem::Class.

# Copyright (C) 2009-2010 Simon Dawson
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

package Cat;

use strict;
use warnings;
use diagnostics;

sub new { my $c = shift; return bless({'name' => shift}, __PACKAGE__); };

1;
