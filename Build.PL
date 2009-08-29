#!/usr/bin/perl -w
#
#D Build script for Phloem.

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

use Module::Build;

my $builder =
  Module::Build->new('module_name' => 'Phloem::App',
                     'dist_author' => 'Simon Dawson <spdawson@gmail.com>',
                     'license'     => 'gpl',
                     'requires'    => {'perl'        => '5.10.0',
                                       'XML::Simple' => 0},
                     'recursive_test_files' => 1);

$builder->create_build_script();
